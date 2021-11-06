#
#
#
class profile_hypervisor::network (
  String $physical_interface      = $::profile_hypervisor::physical_interface,
  String $native_vlan_bridge_name = $::profile_hypervisor::native_vlan_bridge_name,
  Hash   $br_interfaces           = $::profile_hypervisor::br_interfaces,
  Hash   $br_interfaces_common    = $::profile_hypervisor::br_interfaces_common,
  Hash   $br_interfaces_defaults  = $::profile_hypervisor::br_interfaces_defaults,
) {
  sysctl { 'net.ipv4.ip_forward':
    ensure  => present,
    value   => 1,
    comment => 'allow ipv4 forwarding bridge interface',
  }

  sysctl { 'net.ipv4.conf.all.arp_filter':
    ensure  => present,
    value   => 0,
    comment => 'allow ipv4 arp requests responds from other interface',
  }

  sysctl { 'net.ipv4.conf.all.rp_filter':
    ensure  => present,
    value   => 2,
    comment => 'allow ipv4 loose reverse path filter',
  }

  kmod::load { '8021q': }

  network::interface{ $physical_interface:
    enable               => true,
    method               => 'manual',
    bridge               => $native_vlan_bridge_name,
    options_extra_debian => {
      'ethtool-wol' => 'g',
      'up'          => "/sbin/ethtool -s ${physical_interface} wol g",
    },
  }

  @@profile_proxy::wake_on_lan::host { $facts['networking']['fqdn']:
    mac => $facts['networking']['interfaces'][$physical_interface]['mac'],
    ip  => $facts['networking']['interfaces'][$native_vlan_bridge_name]['ip'],
  }

  create_resources(profile_hypervisor::network::br, deep_merge($br_interfaces, $br_interfaces_common), $br_interfaces_defaults)
}
