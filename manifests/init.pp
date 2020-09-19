class profile_hypervisor (
  String          $br0_ipaddress,
  String          $br0_netmask,
  String          $br0_gateway,
  String          $br1_ipaddress,
  String          $br1_netmask,
  Hash            $iso_files          = $::profile_hypervisor::params::iso_files,
  Hash            $virtual_machines   = $::profile_hypervisor::params::virtual_machines,
  Array[String]   $packages           = $::profile_hypervisor::params::packages,
  String          $libvirt_service    = $::profile_hypervisor::params::libvirt_services,
  Boolean         $enable_cockpit     = $::profile_hypervisor::params::enable_cockpit,
  String          $iso_path           = $::profile_hypervisor::params::iso_path,
  String          $script_path        = $::profile_hypervisor::params::script_path,
  String          $ks_path            = $::profile_hypervisor::params::ks_path,
  String          $phys_interface     = $::profile_hypervisor::params::phys_interface,
) inherits profile_hypervisor::params {
  package { $packages:
    ensure => present,
  }

  service { $libvirt_service:
    ensure => running,
    enable => true,
  }

  group { 'libvirt':
    ensure  => present,
    members => ['root'],
  }

  file { [$iso_path,$script_path,$ks_path]:
    ensure => directory,
    owner  => 'root',
    group  => 'libvirt',
  }

  # Add cockpit support el8
  if $facts['os']['family'] == 'RedHat' and $facts['os']['release']['major'] == '8' and $enable_cockpit {
    package { ['cockpit','cockpit-machines']:
      ensure => present,
    }
    service { 'cockpit':
      ensure => running,
      enable => true,
    }
    firewall { '200 allow cockpit':
      dport  => 9090,
      action => 'accept',
    }
  }

  # Network
  if $facts['os']['release']['major'] != '8' {
    package { 'bridge-utils':
      ensure => present,
    }
  }

  sysctl{ 'net.ipv4.ip_forward':
    ensure  => present,
    value   => 1,
    comment => 'allow ipv4 forwarding bridge interface',
  }

  network::interface{ $phys_interface:
    enable    => true,
    bootproto => 'static',
    bridge    => 'br0',
  }
  network::interface{ 'br0':
    enable    => true,
    type      => 'bridge',
    bootproto => 'static',
    ipaddress => $br0_ipaddress,
    netmask   => $br0_netmask,
  }
  network::route { 'br0':
    ipaddress => ['0.0.0.0'],
    netmask   => ['0.0.0.0'],
    gateway   => [$br0_gateway],
  }
  network::interface{ 'br1':
    enable    => true,
    type      => 'bridge',
    bootproto => 'static',
    ipaddress => $br1_ipaddress,
    netmask   => $br1_netmask,
  }
  create_resources(profile_hypervisor::iso_file, $iso_files)
  create_resources(profile_hypervisor::virtual_machine, $virtual_machines)
}
