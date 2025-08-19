# == Class: openstack_extras::repo::debian::ubuntu
#
# This repo sets up apt sources for use with the debian
# osfamily and ubuntu operatingsystem
#
# === Parameters:
#
# [*release*]
#   (optional) The OpenStack release to add an Ubuntu Cloud Archive APT source
#   for.
#   Defaults to 'epoxy'
#
# [*manage_uca*]
#   (optional) Whether or not to add the default Ubuntu Cloud Archive APT
#   source.
#   Defaults to true
#
# [*repo*]
#   (optional) Select with repository we want to use
#   Can be 'updates' or 'proposed'
#   'proposed' to test upgrade to the next version
#   'updates' to install the latest stable version
#   Defaults to 'updates'
#
# [*source_hash*]
#   (optional) A hash of apt::source resources to
#   create and manage
#   Defaults to {}
#
# [*source_defaults*]
#   (optional) A hash of defaults to use for all apt::source
#   resources created by this class
#   Defaults to {}
#
# [*package_require*]
#   (optional) Whether or not to run 'apt-get update' before
#   installing any packages.
#   Defaults to false
#
# [*uca_location*]
#   (optional) Ubuntu Cloud Archives repository location.
#   Defaults to $::openstack_extras::repo::debian::params::uca_location
#
class openstack_extras::repo::debian::ubuntu (
  String[1] $release                = 'epoxy',
  Boolean $manage_uca               = true,
  Enum['updates', 'proposed'] $repo = 'updates',
  Hash $source_hash                 = {},
  Hash $source_defaults             = {},
  Boolean $package_require          = false,
  String[1] $uca_location           = 'http://ubuntu-cloud.archive.canonical.com/ubuntu',
) {
  if $manage_uca {
    exec { 'installing ubuntu-cloud-keyring':
      command     => '/usr/bin/apt-get -y install ubuntu-cloud-keyring',
      logoutput   => 'on_failure',
      tries       => 3,
      try_sleep   => 1,
      refreshonly => true,
      subscribe   => File['/etc/apt/sources.list.d/ubuntu-cloud-archive.list'],
      notify      => Exec['apt_update'],
    }
    apt::source { 'ubuntu-cloud-archive':
      location => $uca_location,
      release  => "${facts['os']['distro']['codename']}-${repo}/${release}",
      repos    => 'main',
    }
  }

  create_resources('apt::source', $source_hash, $source_defaults)

  if $package_require {
    Exec['apt_update'] -> Package<||>
  }
}
