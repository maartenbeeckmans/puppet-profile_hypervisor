#
#
#
class profile_hypervisor (
  Array[String] $packages,
  String        $libvirt_service,
  String        $libvirt_user,
  String        $libvirt_group,
  String        $volume_group,

  String        $physical_interface,
  String        $native_vlan_bridge_name,
  Hash          $br_interfaces,
  Hash          $br_interfaces_common,
  Hash          $br_interfaces_defaults,

  String        $terraform_password,
  String        $terraform_ssh_key,
) {
  include profile_hypervisor::libvirt
  include profile_hypervisor::lvm
  include profile_hypervisor::network
  include profile_hypervisor::terraform
}
