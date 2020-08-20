# dependencies: puppet-archive
#
# profile_hypervisor::iso_file:
#   centos-8.8.iso:
#     url: centos.org/blabla
define profile_hypervisor::iso_file (
  String  $iso_path = $::profile_hypervisor::iso_file,
  String  $url,
) {
  archive { "${iso_file}${name}":
    ensure   => present,
    extract  => false,
    source   => $url,
    user     => 'root',
    group    => 'libvirt',
    provider => 'wget',
  }
}
