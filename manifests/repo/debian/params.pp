# == Class: openstack_extras::repo::debian::params
#
# This repo sets defaults for the debian osfamily
#
class openstack_extras::repo::debian::params
{
  $release               = 'xena'

  $uca_name              = 'ubuntu-cloud-archive'
  $uca_location          = 'http://ubuntu-cloud.archive.canonical.com/ubuntu'
  $uca_repos             = 'main'
  $uca_required_packages = 'ubuntu-cloud-keyring'

  $deb_name              = 'debian-openstack-backports'
  $deb_repos             = 'main'
  $deb_required_packages = 'openstack-backports-archive-keyring'
}
