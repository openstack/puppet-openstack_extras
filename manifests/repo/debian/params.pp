# == Class: openstack_extras::repo::debian::params
#
# This repo sets defaults for the debian osfamily
#
class openstack_extras::repo::debian::params
{
  $release               = 'kilo'

  $uca_name              = 'ubuntu-cloud-archive'
  $uca_location          = 'http://ubuntu-cloud.archive.canonical.com/ubuntu'
  $uca_repos             = 'main'
  $uca_required_packages = 'ubuntu-cloud-keyring'

  $whz_name              = 'debian_wheezy'
  $whz_location          = 'http://archive.gplhost.com/debian'
  $whz_repos             = 'main'
  $whz_required_packages = 'gplhost-archive-keyring'
}
