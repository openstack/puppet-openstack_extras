# == Class: openstack_extras::repo::debian::ubuntu
#
# This repo sets up apt sources for use with the debian
# osfamily and ubuntu operatingsystem
#
# === Parameters:
#
# [*release*]
#   (optional) The OpenStack release to add an
#   Ubuntu Cloud Archive APT source for.
#   Defaults to 'liberty'
#
# [*manage_uca*]
#   (optional) Whether or not to add the default
#   Ubuntu Cloud Archive APT source
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
class openstack_extras::repo::debian::ubuntu(
  $release         = $::openstack_extras::repo::debian::params::release,
  $manage_uca      = true,
  $repo            = 'updates',
  $source_hash     = {},
  $source_defaults = {},
  $package_require = false
) inherits openstack_extras::repo::debian::params {
  if $manage_uca {
    exec { 'installing ubuntu-cloud-keyring':
      command     => '/usr/bin/apt-get -y install ubuntu-cloud-keyring',
      logoutput   => 'on_failure',
      tries       => 3,
      try_sleep   => 1,
      refreshonly => true,
      subscribe   => File["/etc/apt/sources.list.d/${::openstack_extras::repo::debian::params::uca_name}.list"],
      notify      => Exec['apt_update'],
    }
    apt::source { $::openstack_extras::repo::debian::params::uca_name:
      location => $::openstack_extras::repo::debian::params::uca_location,
      release  => "${::lsbdistcodename}-${repo}/${release}",
      repos    => $::openstack_extras::repo::debian::params::uca_repos,
    }
  }

  create_resources('apt::source', $source_hash, $source_defaults)

  if $package_require {
    Exec['apt_update'] -> Package<||>
  }
}
