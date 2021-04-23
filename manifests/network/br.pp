#
#
#
define profile_hypervisor::network::br (
  Stdlib::IP::Address::V4::CIDR     $ip_address_cidr,
  String                            $physical_interface = $::profile_hypervisor::network::physical_interface,
  String $native_vlan_bridge_name = $::profile_hypervisor::native_vlan_bridge_name,
  String                            $interface_name     = $title,
  Optional[Integer]                 $vlan_id            = undef,
  Optional[Stdlib::IP::Address::V4] $gateway            = undef,
) {
  # These functions are defined https://github.com/inkblot/puppet-ipcalc
  $_ip_address    = ip_address($ip_address_cidr)
  $_netmask       = ip_netmask($ip_address_cidr)
  $_local_network = ip_network($ip_address_cidr, 0)

  if $vlan_id {
    network::interface { "${physical_interface}.${vlan_id}":
      enable  => true,
      bridge  => $interface_name,
      type    => 'vlan',
      method  => 'manual',
      physdev => $physical_interface
    }

    network::interface { $interface_name:
      enable    => true,
      ipaddress => $_ip_address,
      netmask   => $_netmask,
      method    => 'static',
      bridge_ports => ["${physical_interface}.${vlan_id}"],
      bridge_stp   => 'off',
      bridge_fd    => 0,
      bridge_waitport => 0,
    }
  } else {
    network::interface { $interface_name:
      enable    => true,
      ipaddress => $_ip_address,
      netmask   => $_netmask,
      method    => 'static',
      bridge_ports => [$physical_interface],
      bridge_stp   => 'off',
      bridge_fd    => 0,
      bridge_waitport => 0,
    }
  }

  if $gateway {
    network::route { $interface_name:
      ipaddress => ['0.0.0.0'],
      netmask   => ['0.0.0.0'],
      gateway   => [$gateway],
    }
  }

  firewall { "00013 ${interface_name} allow outgoing established":
    outiface    => $interface_name,
    destination => $_local_network,
    proto       => 'all',
    state       => ['RELATED', 'ESTABLISHED'],
    chain       => 'FORWARD',
    action      => 'accept',
  }
  firewall { "00014 ${interface_name} allow subnet":
    iniface => $interface_name,
    proto   => 'all',
    chain   => 'FORWARD',
    action  => 'accept',
  }
  firewall { "00201 outgoing traffic SNAT ${_local_network}":
    jump     => 'SNAT',
    chain    => 'POSTROUTING',
    table    => 'nat',
    outiface => $native_vlan_bridge_name,
    proto    => 'all',
    source   => $_local_network,
    tosource => ip_address(getparam(Profile_hypervisor::Network::Br[$native_vlan_bridge_name], 'ip_address_cidr')),
  }
}
