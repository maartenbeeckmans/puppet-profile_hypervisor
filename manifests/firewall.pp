#
#
#
class profile_hypervisor::firewall (
  String $br1_ipaddress,
  String $kvm_bridge    = 'br0',
  String $local_network = '192.168.0.0/24',
) {
  firewall { "00013 ${kvm_bridge} allow outgoing established":
    destination => $local_network,
    outiface    => $kvm_bridge,
    proto       => 'all',
    state       => ['RELATED','ESTABLISHED'],
    chain       => 'FORWARD',
    action      => 'accept',
  }

  firewal { "00014 ${kvm_bridge} allow subnet":
    iniface => $kvm_bridge,
    proto   => 'all',
    chain   => 'FORWARD',
    action  => 'accept',
  }

  firewall { '00015 forward any':
    proto  => 'all',
    chain  => 'FORWARD',
    action => 'accept',
  }

  firewall { '00201 outgoing traffic SNAT':
    jump     => 'SNAT',
    chain    => 'POSTROUTING',
    table    => 'nat',
    outiface => 'br1',
    proto    => 'all',
    source   => $local_network,
    tosource => $br1_ipaddress,
  }
}
