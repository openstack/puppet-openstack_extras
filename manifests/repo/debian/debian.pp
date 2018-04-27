# == Class: openstack_extras::repo::debian::debian
#
# This repo sets up apt sources for use with the debian
# osfamily and debian operatingsystem
#
# === Parameters:
#
# [*release*]
#   (optional) The OpenStack release to add a
#   Debian Stretch apt source for.
#   Defaults to $::openstack_extras::repo::debian::params::release
#
# [*manage_deb*]
#   (optional) Whether or not to add the default
#   Debian Stretch APT source
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
# [*deb_location*]
#   (optional) Debian package repository location.
#   Defaults to "http://${::lsbdistcodename}-${release}.debian.net/debian"
#
# === DEPRECATED
#
# [*manage_whz*]
#   (optional) Whether or not to add the default Debian Stretch APT source
#   Replaced by $manage_deb.
#
class openstack_extras::repo::debian::debian(
  $release         = $::openstack_extras::repo::debian::params::release,
  $manage_deb      = true,
  $source_hash     = {},
  $source_defaults = {},
  $package_require = false,
  $deb_location    = "http://${::lsbdistcodename}-${release}.debian.net/debian",
  # DEPRECATED
  $manage_whz      = undef,
) inherits openstack_extras::repo::debian::params {
  # handle deprecation
  $deb_manage = pick($manage_whz, $manage_deb)
  if $deb_manage {
    exec { 'installing openstack-backports-archive-keyring':
      command     => "/usr/bin/apt-get update ; \
                   /usr/bin/apt-get -y --allow-unauthenticated install ${::openstack_extras::repo::debian::params::deb_required_packages}",
      logoutput   => 'on_failure',
      tries       => 3,
      try_sleep   => 1,
      refreshonly => true,
      subscribe   => File["/etc/apt/sources.list.d/${::openstack_extras::repo::debian::params::deb_name}.list"],
      notify      => Exec['apt_update'],
    }
    apt::source { $::openstack_extras::repo::debian::params::deb_name:
      location => $deb_location,
      release  => "${::lsbdistcodename}-${release}-backports",
      repos    => $::openstack_extras::repo::debian::params::deb_repos,
    }
    -> apt::source { "${::openstack_extras::repo::debian::params::deb_name}-nochange":
      location => $deb_location,
      release  => "${::lsbdistcodename}-${release}-backports-nochange",
      repos    => $::openstack_extras::repo::debian::params::deb_repos,
    }
  }

  create_resources('apt::source', $source_hash, $source_defaults)

  if $package_require {
    Exec['apt_update'] -> Package<||>
  }
}
