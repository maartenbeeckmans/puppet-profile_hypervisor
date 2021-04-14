#
#
#
class profile_hypervisor (
  Array[String] $packages,
  String        $libvirt_service,
  String        $physical_interface,
  String        $native_vlan_bridge_name,
  Hash          $br_interfaces,
  Hash          $br_interfaces_defaults,
) {
  include profile_hypervisor::libvirt
  include profile_hypervisor::network
  include profile_hypervisor::terraform
}
