#
#
#
class profile_hypervisor::network (
  String $physical_interface      = $::profile_hypervisor::physical_interface,
  String $native_vlan_bridge_name = $::profile_hypervisor::native_vlan_bridge_name,
  Hash   $br_interfaces           = $::profile_hypervisor::br_interfaces,
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
    enable => true,
    method => 'manual',
    bridge => $native_vlan_bridge_name,
  }
  create_resources(profile_hypervisor::network::br, $br_interfaces, $br_interfaces_defaults)
}
