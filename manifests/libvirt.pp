#
#
#
class profile_hypervisor::libvirt (
  Array[String]   $packages        = $::profile_hypervisor::packages,
  String          $libvirt_service = $::profile_hypervisor::libvirt_service,
) {
  package { $packages:
    ensure => present,
  }

  service { $libvirt_service:
    ensure => running,
    enable => true,
  }
}
