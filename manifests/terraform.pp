#
#
#
class profile_hypervisor::terraform (
  String $password = $::profile_hypervisor::terraform_password,
  String $ssh_key  = $::profile_hypervisor::terraform_ssh_key,
) {
  accounts::user { 'terraform':
    comment      => 'Terraform user used for libvirt provider',
    create_group => true,
    groups       => ['libvirt'],
    password     => $password,
    ssh_key      => $ssh_key,
  }
}
