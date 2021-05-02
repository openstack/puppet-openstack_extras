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
# [*manage_virt*]
#   (Optional) Whether to create a yumrepo resource for the
#   Advanced Virtualization repository.
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
#   Defaults to 'http://mirror.centos.org'
#
# [*update_packages*]
#   (Optional) Whether to update all packages after yum repositories are
#   configured.
#   Defaults to false
#
# [*stream*]
#   (Optional) Is this CentOS Stream and should we adjust mirrors.
#   Defaults to true
#
# DEPRECATED PARAMS
# =================
#
# [*manage_priorities*]
#   (Optional) Whether to install yum-plugin-priorities package so
#   'priority' value in yumrepo will be effective.
#   Defaults to undef
#
class openstack_extras::repo::redhat::redhat (
  $release           = $openstack_extras::repo::redhat::params::release,
  $manage_rdo        = true,
  $manage_virt       = true,
  $manage_epel       = false,
  $repo_hash         = {},
  $repo_source_hash  = {},
  $repo_replace      = true,
  $repo_defaults     = {},
  $gpgkey_hash       = {},
  $gpgkey_defaults   = {},
  $purge_unmanaged   = false,
  $package_require   = false,
  $centos_mirror_url = 'http://mirror.centos.org',
  $update_packages   = false,
  $stream            = true,
  # DEPRECATED PARAMS
  $manage_priorities = undef,
) inherits openstack_extras::repo::redhat::params {

  validate_legacy(String, 'validate_string', $release)
  validate_legacy(Boolean, 'validate_bool', $manage_rdo)
  validate_legacy(Boolean, 'validate_bool', $manage_epel)
  validate_legacy(Hash, 'validate_hash', $repo_hash)
  validate_legacy(Hash, 'validate_hash', $repo_source_hash)
  validate_legacy(Hash, 'validate_hash', $repo_defaults)
  validate_legacy(Hash, 'validate_hash', $gpgkey_hash)
  validate_legacy(Hash, 'validate_hash', $gpgkey_defaults)
  validate_legacy(Boolean, 'validate_bool', $purge_unmanaged)
  validate_legacy(Boolean, 'validate_bool', $package_require)
  validate_yum_hash($repo_hash)

  if $manage_priorities != undef {
    warning('openstack_extras::repo::redhat::redhat::manage_priorities parameter is deprecated and will be removed')
  }

  $_repo_defaults = merge($openstack_extras::repo::redhat::params::repo_defaults, $repo_defaults)
  $_gpgkey_defaults = merge($openstack_extras::repo::redhat::params::gpgkey_defaults, $gpgkey_defaults)

  $centos_major = $stream ? {
    true    => "${facts['os']['release']['major']}-stream",
    default => $facts['os']['release']['major']
  }

  anchor { 'openstack_extras_redhat': }

  if $manage_rdo {
    $release_cap = capitalize($release)

    $rdo_hash = {
      'rdo-release' => {
        'baseurl'  => "${centos_mirror_url}/centos/${centos_major}/cloud/\$basearch/openstack-${release}/",
        'descr'    => "OpenStack ${release_cap} Repository",
        'gpgkey'   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Cloud',
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

  if $manage_virt and ($facts['os']['name'] != 'Fedora') {
    if $stream {
      $virt_baseurl = "${centos_mirror_url}/centos/${centos_major}/virt/\$basearch/advancedvirt-common/"
    } else {
      $virt_baseurl = "${centos_mirror_url}/centos/${centos_major}/virt/\$basearch/advanced-virtualization/"
    }

    $virt_hash = {
      'rdo-qemu-ev' => {
        'baseurl' => $virt_baseurl,
        'descr'   => "RDO CentOS-${$centos_major} - QEMU EV",
        'gpgkey'  => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Virtualization',
      }
    }

    $virtkey_hash = {
      '/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Virtualization' => {
        'source' => 'puppet:///modules/openstack_extras/RPM-GPG-KEY-CentOS-SIG-Virtualization'
      }
    }

    create_resources('file', $virtkey_hash, $_gpgkey_defaults)
    create_resources('yumrepo', $virt_hash, $_repo_defaults)
  }

  if ($manage_epel and $facts['os']['name'] != 'Fedora') {
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
      timeout     => 600,
    }

    Exec['yum_refresh'] ~> Exec['yum_update'] -> Package <||>
  }
  else {
    Exec['yum_refresh'] -> Package <||>
  }
}
