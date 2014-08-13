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
#   Defaults to 'icehouse'
#
# [*manage_uca*]
#   (optional) Whether or not to add the default
#   Ubuntu Cloud Archive APT source
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
class openstack_extras::repo::debian::ubuntu(
  $release         = $::openstack_extras::repo::debian::params::release,
  $manage_uca      = true,
  $source_hash     = {},
  $source_defaults = {},
  $package_require = false
) inherits openstack_extras::repo::debian::params {
  if $manage_uca {
    apt::source { $::openstack_extras::repo::debian::params::uca_name:
      location          => $::openstack_extras::repo::debian::params::uca_location,
      release           => "${::lsbdistcodename}-updates/${release}",
      repos             => $::openstack_extras::repo::debian::params::uca_repos,
      required_packages => $::openstack_extras::repo::debian::params::uca_required_packages
    }
  }

  create_resources('apt::source', $source_hash, $source_defaults)

  if $package_require {
    Exec['apt_update'] -> Package<||>
  }
}
