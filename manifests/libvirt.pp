#
#
#
class profile_hypervisor::libvirt (
  Array[String]   $packages        = $::profile_hypervisor::packages,
  String          $libvirt_service = $::profile_hypervisor::libvirt_services,
) {
  package { $packages:
    ensure => present,
  }

  service { $libvirt_service:
    ensure => running,
    enable => true,
  }

  group { 'libvirt':
    ensure  => present,
    members => ['root', 'terraform'],
  }
}
