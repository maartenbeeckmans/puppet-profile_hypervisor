define profile_hypervisor::virtual_machine (
  String          $vm_ensure              = $::profile_hypervisor::params::vm_ensure,
  String          $vm_cpus                = $::profile_hypervisor::params::vm_cpus,
  String          $vm_memory              = $::profile_hypervisor::params::vm_memory,
  String          $vm_storage_size        = $::profile_hypervisor::params::vm_storage_size,
  String          $vm_lvm_var_size        = $::profile_hypervisor::params::vm_lvm_var_size,
  String          $vm_lvm_swap_size       = $::profile_hypervisor::params::vm_lvm_swap_size,
  String          $vm_os_type             = $::profile_hypervisor::params::vm_os_type,
  String          $vm_os_variant          = $::profile_hypervisor::params::vm_os_variant,
  String          $vm_network_bridge      = $::profile_hypervisor::params::vm_network_bridge,
  String          $vm_network_interface   = $::profile_hypervisor::params::vm_network_interface,
  String          $vm_network_ip,
  String          $vm_network_netmask     = $::profile_hypervisor::params::vm_network_netmask,
  Array[String]   $vm_network_nameservers = $::profile_hypervisor::params::vm_network_nameservers,
  String          $vm_repo_puppet_url     = $::profile_hypervisor::params::vm_repo_puppet_url,
  String          $vm_iso_file            = $::profile_hypervisor::params::iso,
  String          $vm_ks_file             = $::profile_hypervisor::params::kickstart,
  String          $vm_root_pw             = $::profile_hypervisor::params::vm_root_pw,
  String          $host_lvm_vg            = $::profile_hypervisor::params::host_lvm_vg,
  String          $iso_path               = $::profile_hypervisor::params::iso_path,
  String          $script_path            = $::profile_hypervisor::script_path,
  String          $ks_path                = $::profile_hypervisor::ks_path,
) {
  # To do, check if iso file is present, otherwise throw warning
  $vm_hostname = $name
  # Ensure LVM logical volume is created
  logical_volume { $vm_hostname:
    ensure       => $vm_ensure,
    volume_group => $host_lvm_vg,
    size         => $vm_storage_size,
  }
  if $vm_ensure == 'present' {
    # Ensure kickstart file is created
    file {"${ks_path}/${vm_hostname}.cfg":
      ensure  => file,
      owner   => 'root',
      group   => 'libvirt',
      content => epp("${module_name}/virtual_machine/kickstart.cfg.epp"),
    }

    # Ensure creation script is created
    file {"${script_path}/puppet-virtinstall-${vm_hostname}.sh":
      ensure  => file,
      mode    => '0775',
      owner   => 'root',
      group   => 'libvirt',
      content => epp("${module_name}/virtual_machine/virt-install.sh.epp"),
    }

    # Create virtual machine
    exec { "${script_path}/puppet-install-${vm_hostname}.sh":
      user   => 'root',
      group  => 'libvirt',
      onlyif => "/bin/bash -c '! virsh domstate ${vm_hostname}'",
    }
  } elsif $vm_ensure == 'absent' {
    file { "/tmp/${vm_hostname}.cfg":
      ensure => absent,
    }
    file {"/tmp/puppet-install-${vm_hostname}.sh":
      ensure => absent,
    }
    exec{"virsh destroy ${vm_hostname}":
      user   => 'root',
      group  => 'libvirt',
      path   => ['/usr/bin/','/bin/'],
      onlyif => [ "/bin/bash -c ' virsh domstate ${vm_hostname}' ",
                  "/bin/bash -c 'virsh domstate ${vm_hostname} |
                  grep 'running'' "]
      }
    ->exec{"virsh undefine ${vm_hostname}":
      user   => 'root',
      group  => 'libvirt',
      path   => ['/usr/bin/','/bin/'],
      onlyif => [ "/bin/bash -c ' virsh domstate ${vm_hostname}' ",
                  "/bin/bash -c 'virsh domstate ${vm_hostname} |
                  grep 'shut off'' "]
    }
  }
}
