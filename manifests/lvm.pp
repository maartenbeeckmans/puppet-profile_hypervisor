#
#
#
class profile_hypervisor::lvm (
  String $volume_group  = $::profile_hypervisor::volume_group,
  String $libvirt_user  = $::profile_hypervisor::libvirt_user,
  String $libvirt_group = $::profile_hypervisor::libvirt_group,
) {
  logical_volume { 'libvirt_cloudinit_pool':
    ensure       => present,
    volume_group => $volume_group,
    initial_size => '5G',
  }

  logical_volume { 'libvirt_domains_pool':
    ensure       => present,
    volume_group => $volume_group,
    initial_size => '100G',
  }

  logical_volume { 'libvirt_images_pool':
    ensure       => present,
    volume_group => $volume_group,
    initial_size => '25G',
  }

  profile_base::mount { '/var/lib/libvirt/cloudinit_pool':
    device => "/dev/${volume_group}/libvirt_cloudinit_pool",
    owner  => $libvirt_user,
    group  => $libvirt_group,
  }

  profile_base::mount { '/var/lib/libvirt/domains_pool':
    device => "/dev/${volume_group}/libvirt_domains_pool",
    owner  => $libvirt_user,
    group  => $libvirt_group,
  }

  profile_base::mount { '/var/lib/libvirt/images_pool':
    device => "/dev/${volume_group}/libvirt_images_pool",
    owner  => $libvirt_user,
    group  => $libvirt_group,
  }
}
