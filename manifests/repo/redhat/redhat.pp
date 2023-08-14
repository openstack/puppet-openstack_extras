# == Class: openstack_extras::repo::redhat::redhat
#
# This class sets up repositories for use with the supported
# operating systems in the RedHat OS family.
#
# === Parameters:
#
# [*release*]
#   (Optional) The OpenStack release to use.
#   Defaults to $openstack_extras::repo::redhat::params::release
#
# [*manage_rdo*]
#   (Optional) Whether to create a yumrepo resource for the
#   RDO OpenStack repository.
#   Defaults to true
#
# [*manage_epel*]
#   (Optional) Whether to create a predefined yumrepo resource for
#   the EPEL repository. Note EPEL is not required for deploying
#   OpenStack with RDO.
#   Defaults to false
#
# [*repo_hash*]
#   (Optional) A hash of yumrepo resources that will be passed to
#   create_resource. See examples folder for some useful examples.
#   Defaults to {}
#
# [*repo_source_hash*]
#   (Optional) A hash of repo files.
#   Defaults to {}
#
# [*repo_replace*]
#   (Optional) Replace repo files when their contents are changed.
#   Defaults to true
#
# [*repo_defaults*]
#   (Optional) The defaults for the yumrepo resources that will be
#   created using create_resource.
#   Defaults to $openstack_extras::repo::redhat::params::repo_defaults
#
# [*gpgkey_hash*]
#   (Optional) A hash of file resources that will be passed to
#   create_resources. See examples folder for some useful examples.
#   Defaults to {}
#
# [*gpgkey_defaults*]
#   (Optional) The default resource attributes to create gpgkeys with.
#   Defaults to $openstack_extras::repo::redhat::params::gpgkey_defaults
#
# [*purge_unmanaged*]
#   (Optional) Purge the yum.repos.d directory of all repositories
#   not managed by Puppet.
#   Defaults to false
#
# [*package_require*]
#   (Optional) Set all packages to require all yumrepos be set.
#   Defaults to false
#
# [*centos_mirror_url*]
#   (Optional) URL of CentOS mirror.
#   Defaults to $openstack_extras::repo::redhat::params::centos_mirror_url
#
# [*update_packages*]
#   (Optional) Whether to update all packages after yum repositories are
#   configured.
#   Defaults to false
#
# [*update_timeout*]
#   (Optional) Timeout for package update.
#   Defaults to 600
#
class openstack_extras::repo::redhat::redhat (
  String[1] $release           = $openstack_extras::repo::redhat::params::release,
  Boolean $manage_rdo          = true,
  Boolean $manage_epel         = false,
  Hash $repo_hash              = {},
  Hash $repo_source_hash       = {},
  Boolean $repo_replace        = true,
  Hash $repo_defaults          = {},
  Hash $gpgkey_hash            = {},
  Hash $gpgkey_defaults        = {},
  Boolean $purge_unmanaged     = false,
  Boolean $package_require     = false,
  String[1] $centos_mirror_url = $openstack_extras::repo::redhat::params::centos_mirror_url,
  Boolean $update_packages     = false,
  Integer[0] $update_timeout   = 600,
) inherits openstack_extras::repo::redhat::params {

  validate_yum_hash($repo_hash)

  $_repo_defaults = merge($openstack_extras::repo::redhat::params::repo_defaults, $repo_defaults)
  $_gpgkey_defaults = merge($openstack_extras::repo::redhat::params::gpgkey_defaults, $gpgkey_defaults)

  anchor { 'openstack_extras_redhat': }

  if $manage_rdo {
    $release_cap = capitalize($release)

    $rdo_baseurl = "${centos_mirror_url}/SIGs/\$stream/cloud/\$basearch/openstack-${release}/"

    $rdo_hash = {
      'rdo-release' => {
        'baseurl'         => $rdo_baseurl,
        'descr'           => "OpenStack ${release_cap} Repository",
        'gpgkey'          => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Cloud',
        'module_hotfixes' => true,
      }
    }

    $rdokey_hash = {
      '/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Cloud' => {
        'source' => 'puppet:///modules/openstack_extras/RPM-GPG-KEY-CentOS-SIG-Cloud'
      }
    }

    create_resources('file', $rdokey_hash, $_gpgkey_defaults)
    create_resources('yumrepo', $rdo_hash, $_repo_defaults)
  }

  if $manage_epel {
    $epel_hash = {
      'epel' => {
        'metalink'       => "https://mirrors.fedoraproject.org/metalink?repo=epel-${facts['os']['release']['major']}&arch=\$basearch",
        'descr'          => "Extra Packages for Enterprise Linux ${facts['os']['release']['major']} - \$basearch",
        'gpgkey'         => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-${facts['os']['release']['major']}",
        'failovermethod' => 'priority'
      }
    }

    $epelkey_hash = {
      "/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-${facts['os']['release']['major']}" => {
        'source' => "puppet:///modules/openstack_extras/RPM-GPG-KEY-EPEL-${facts['os']['release']['major']}"
      }
    }

    create_resources('file', $epelkey_hash, $_gpgkey_defaults)
    create_resources('yumrepo', $epel_hash, $_repo_defaults)
  }

  create_resources('yumrepo', $repo_hash, $_repo_defaults)
  create_resources('file', $gpgkey_hash, $_gpgkey_defaults)

  $repo_source_hash.each |$filename, $url| {
    file { $filename:
      path    => "/etc/yum.repos.d/${filename}",
      source  => $url,
      replace => $repo_replace,
      notify  => Exec['yum_refresh'],
    }
  }

  if $purge_unmanaged {
    resources { 'yumrepo':
      purge => true
    }
  }

  if $package_require {
    Yumrepo<||> -> Package<||>
  }

  exec { 'yum_refresh':
    command     => '/usr/bin/dnf clean all',
    refreshonly => true,
  }

  if $update_packages {
    exec { 'yum_update':
      command     => '/usr/bin/dnf update -y',
      refreshonly => true,
      timeout     => $update_timeout,
    }

    Exec['yum_refresh'] ~> Exec['yum_update'] -> Package <||>
  }
  else {
    Exec['yum_refresh'] -> Package <||>
  }
}
