class profile_hypervisor::params {
  # OS specifiec information
  case $::osfamily {
    'Debian': {
      $packages = ['qemu', 'qemu-kvm', 'qemu-system', 'qemu-utils', 'libvirt-clients', 'libvirt-deamon-system', 'virtinst']
      $libvirt_service = 'libvirtd'
    }
    'RedHat': {
      $packages = ['qemu', 'qemu-kvm', 'qemu-system', 'qemu-utils', 'libvirt-clients', 'libvirt-deamon-system', 'virtinst']
      $libvirt_service = 'libvirtd'
    }
    default: {
      fail('Operating System Not supported')
    }
  }
  $enable_cockpit = false

  # ISO files hash
  $iso_files = {
    'centos-8.2-minimal' => {
      url => 'http://ftp.belnet.be/mirror/ftp.centos.org/8.2.2004/isos/x86_64/CentOS-8.2.2004-x86_64-minimal.iso',
    }
  }
  # Virtual machine hash
  $virtual_machines = {}

  # Default path
  $iso_path = '/var/libvirt/iso'
  $script_path = '/var/libvirt/scripts'
  $ks_path = '/var/libvirt/ks_files'

  # Get first physical interface
  $iface_array = split($::interfaces,',')
  $phys_interface template("${module_name}/get_physical_interface.erb")
}
