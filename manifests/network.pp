#
#
#
class profile_hypervisor::network (
) {
  sysctl { 'net.ipv4.ip_forward':
    value => '1',
  }
}
