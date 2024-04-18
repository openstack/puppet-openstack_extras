# == Class: openstack_extras::repo::debian::debian
#
# This repo sets up apt sources for use with the debian
# osfamily and debian operatingsystem
#
# === Parameters:
#
# [*release*]
#   (optional) The OpenStack release to add a
#   Debian apt source for.
#   Defaults to 'caracal'
#
# [*manage_deb*]
#   (optional) Whether or not to add the default
#   Debian APT source
#   Defaults to true
#
# [*package_require*]
#   (optional) Whether or not to run 'apt-get update' before
#   installing any packages.
#   Defaults to false
#
# [*use_extrepo*]
#   (optional) Should this module use extrepo to
#   setup the Debian apt sources.list. If true, the
#   below parameters aren't in use.
#   Defaults to true.
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
# [*deb_location*]
#   (optional) Debian package repository location.
#   Defaults to "http://${facts['os']['distro']['codename']}-${release}.debian.net/debian"
#
class openstack_extras::repo::debian::debian(
  String[1] $release       = 'caracal',
  Boolean $manage_deb      = true,
  Boolean $package_require = false,
  Boolean $use_extrepo     = true,
  # Below params only used if $use_extrepo is set to false
  Hash $source_hash        = {},
  Hash $source_defaults    = {},
  String[1] $deb_location  = "http://${facts['os']['distro']['codename']}-${release}.debian.net/debian",
) {

  $lowercase_release = downcase($release)

  if $manage_deb {

    if $use_extrepo {
      # Extrepo is much nicer than what's below, because
      # the repositories are authenticated by extrepo itself.
      # Also, using apt-key is now deprecated (to be removed in 2021).
      # We use ensure_packages to avoid conflict with any other class
      # external to this module that may also install extrepo.

      # We cannot use package{} or ensure_packages[] as per below,
      # because this introduces a dependency loop later on if
      # $package_require is set to true.
      # So please leave this commented.
      #ensure_packages(['extrepo',], {'ensure' => 'present'})

      exec { "/usr/bin/extrepo enable openstack_${lowercase_release}":
        command   => "/bin/true # comment to satisfy puppet syntax requirements
apt-get update
apt-get install -y extrepo
extrepo enable openstack_${lowercase_release}
apt-get update
",
        logoutput => 'on_failure',
        tries     => 3,
        try_sleep => 1,
        creates   => "/etc/apt/sources.list.d/extrepo_openstack_${lowercase_release}.sources",
      }
      if $package_require {
        Exec["/usr/bin/extrepo enable openstack_${lowercase_release}"] -> Exec['apt_update']
      }
    }else{
      exec { 'installing openstack-backports-archive-keyring':
        command     => "/usr/bin/apt-get update ; \
                     wget ${deb_location}/dists/pubkey.gpg ; \
                     apt-key add pubkey.gpg ; \
                     rm pubkey.gpg",
        logoutput   => 'on_failure',
        tries       => 3,
        try_sleep   => 1,
        refreshonly => true,
        subscribe   => File['/etc/apt/sources.list.d/debian-openstack-backports.list'],
        notify      => Exec['apt_update'],
      }
      apt::source { 'debian-openstack-backports':
        location => $deb_location,
        release  => "${facts['os']['distro']['codename']}-${lowercase_release}-backports",
        repos    => 'main',
      }
      -> apt::source { 'debian-openstack-backports-nochange':
        location => $deb_location,
        release  => "${facts['os']['distro']['codename']}-${lowercase_release}-backports-nochange",
        repos    => 'main',
      }
    }
    create_resources('apt::source', $source_hash, $source_defaults)
  }

  if $package_require {
    Exec['apt_update'] -> Package<||>
  }
}
