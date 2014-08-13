# == Class: openstack_extras::repo::redhat::redhat
#
# This repo sets up yum repos for use with the redhat
# osfamily and redhat operatingsystem.
#
# === Parameters:
#
# [*release*]
#   (optional) The openstack release to use if managing rdo
#   Defaults to $::openstack_extras::repo::redhat::params::release
#
# [*manage_rdo*]
#   (optional) Whether to create a predefined yumrepo resource
#   for the RDO OpenStack repository provided by RedHat
#   Defaults to true
#
# [*repo_hash*]
#   (optional) A hash of yumrepo resources that will be passed to
#   create_resource. See examples folder for some useful examples.
#   Defaults to {}
#
# [*repo_defaults*]
#   (optional) The defaults for the yumrepo resources that will be
#   created using create_resource.
#   Defaults to $::openstack_extras::repo::redhat::params::repo_defaults
#
# [*gpgkey_hash*]
#   (optional) A hash of file resources that will be passed to
#   create_resource. See examples folder for some useful examples.
#   Defaults to {}
#
# [*gpgkey_defaults*]
#   (optional) The default resource attributes to
#   create gpgkeys with.
#   Defaults to $::openstack_extras::repo::redhat::params::gpgkey_defaults
#
# [*purge_unmanaged*]
#   (optional) Purge the yum.repos.d directory of
#   all repositories not managed by Puppet
#   Defaults to false
#
# [*package_require*]
#   (optional) Set all packages to require all
#   yumrepos be set.
#   Defaults to false
#
class openstack_extras::repo::redhat::redhat(
  $release          = $::openstack_extras::repo::redhat::params::release,
  $manage_rdo       = true,
  $manage_epel      = true,
  $repo_hash        = {},
  $repo_defaults    = {},
  $gpgkey_hash      = {},
  $gpgkey_defaults  = {},
  $purge_unmanaged  = false,
  $package_require  = false
) inherits openstack_extras::repo::redhat::params {

  validate_string($release)
  validate_bool($manage_rdo)
  validate_bool($manage_epel)
  validate_hash($repo_hash)
  validate_hash($repo_defaults)
  validate_hash($gpgkey_hash)
  validate_hash($gpgkey_defaults)
  validate_bool($purge_unmanaged)
  validate_bool($package_require)

  $_repo_defaults = merge($::openstack_extras::repo::redhat::params::repo_defaults, $repo_defaults)
  $_gpgkey_defaults = merge($::openstack_extras::repo::redhat::params::gpgkey_defaults, $gpgkey_defaults)

  anchor { 'openstack_extras_redhat': }

  if $manage_rdo {
    $release_cap = capitalize($release)
    $_dist = $::openstack_extras::repo::redhat::params::dist

    $rdo_hash = { 'rdo-release' => {
        'baseurl'  => "http://repos.fedorapeople.org/repos/openstack/openstack-${release}/${_dist}-${::operatingsystemmajrelease}/",
        'descr'    => "OpenStack ${release_cap} Repository",
        'priority' => $::openstack_extras::repo::redhat::params::rdo_priority,
        'gpgkey'   => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-RDO-${release_cap}",
      }
    }

    $rdokey_hash = { "/etc/pki/rpm-gpg/RPM-GPG-KEY-RDO-${release_cap}" => {
        'source' => "puppet:///modules/openstack_extras/RPM-GPG-KEY-RDO-${release_cap}"
      }
    }

    create_resources('file', $rdokey_hash, $_gpgkey_defaults)
    create_resources('yumrepo', $rdo_hash, $_repo_defaults)
  }

  if $manage_epel {
    if ($::osfamily == 'RedHat' and
        $::operatingsystem != 'Fedora')
    {
      $epel_hash = { 'epel' => {
          'baseurl'         => "https://download.fedoraproject.org/pub/epel/${::operatingsystemmajrelease}/\$basearch",
          'descr'           => "Extra Packages for Enterprise Linux ${::operatingsystemmajrelease} - \$basearch",
          'gpgkey'          => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-${::operatingsystemmajrelease}",
          'failovermethod'  => 'priority'
        }
      }

      $epelkey_hash = { "/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-${::operatingsystemmajrelease}" => {
          'source' => "puppet:///modules/openstack_extras/RPM-GPG-KEY-EPEL-${::operatingsystemmajrelease}"
        }
      }

      create_resources('file', $epelkey_hash, $_gpgkey_defaults)
      create_resources('yumrepo', $epel_hash, $_repo_defaults)
    }
  }

  validate_yum_hash($repo_hash)
  create_resources('yumrepo', $repo_hash, $_repo_defaults)
  create_resources('file', $gpgkey_hash, $_gpgkey_defaults)

  if ((versioncmp($::puppetversion, '3.5') > 0) and $purge_unmanaged) {
      resources { 'yumrepo': purge => true }
  }

  if $package_require {
      Yumrepo<||> -> Package<||>
  }

  exec { 'yum_refresh':
    command     => '/usr/bin/yum clean all',
    refreshonly => true,
  } -> Package <||>
}

