# == Class: openstack_extras::repo::debian::debian
#
# This repo sets up apt sources for use with the debian
# osfamily and debian operatingsystem
#
# === Parameters:
#
# [*release*]
#   (optional) The OpenStack release to add a
#   Debian Wheezy apt source for.
#   Defaults to 'kilo'
#
# [*manage_whz*]
#   (optional) Whether or not to add the default
#   Debian Wheezy APT source
#   Defaults to true
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
class openstack_extras::repo::debian::debian(
  $release         = $::openstack_extras::repo::debian::params::release,
  $manage_whz      = true,
  $source_hash     = {},
  $source_defaults = {},
  $package_require = false
) inherits openstack_extras::repo::debian::params {
  if $manage_whz {
    apt::source { $::openstack_extras::repo::debian::params::whz_name:
      location          => $::openstack_extras::repo::debian::params::whz_location,
      release           => $release,
      repos             => $::openstack_extras::repo::debian::params::whz_repos,
      required_packages => $::openstack_extras::repo::debian::params::whz_required_packages
    } ->
    apt::source { "${::openstack_extras::repo::debian::params::whz_name}_backports":
      location          => $::openstack_extras::repo::debian::params::whz_location,
      release           => "${release}-backports",
      repos             => $::openstack_extras::repo::debian::params::whz_repos,
    }
  }

  create_resources('apt::source', $source_hash, $source_defaults)

  if $package_require {
    Exec['apt_update'] -> Package<||>
  }
}
