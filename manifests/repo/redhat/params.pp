# == Class: openstack_extras::repo::redhat::params
#
# This repo sets defaults for use with the redhat
# OS family repo classes.
#
class openstack_extras::repo::redhat::params {
  $release = 'yoga'

  if versioncmp($::operatingsystemmajrelease, '9') >= 0 {
    $centos_mirror_url = 'http://mirror.stream.centos.org'
    $manage_virt       = false
  } else {
    $centos_mirror_url = 'http://mirror.centos.org'
    $manage_virt       = true
  }

  $repo_defaults = {
    'enabled'    => '1',
    'gpgcheck'   => '1',
    'mirrorlist' => 'absent',
    'notify'     => 'Exec[yum_refresh]',
    'require'    => 'Anchor[openstack_extras_redhat]',
  }

  $gpgkey_defaults = {
    'owner'  => 'root',
    'group'  => 'root',
    'mode'   => '0644',
    'before' => 'Anchor[openstack_extras_redhat]',
  }
}
