#
#
#
class profile_hypervisor::terraform (
  String $password      = $::profile_hypervisor::terraform_password,
  String $ssh_key       = $::profile_hypervisor::terraform_ssh_key,
  String $libvirt_group = $::profile_hypervisor::libvirt_group,
) {
  accounts::user { 'terraform':
    comment      => 'Terraform user used for libvirt provider',
    create_group => true,
    groups       => [$libvirt_group],
    password     => $password,
    sshkeys      => [$ssh_key],
  }
}
