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

  file { '/etc/libvirt/qemu.conf':
    ensure => present,
    source => 'puppet:///modules/profile_hypervisor/qemu.conf',
    notify => Service[$libvirt_service],
  }
}
