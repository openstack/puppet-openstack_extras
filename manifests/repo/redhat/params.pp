# == Class: openstack_extras::repo::redhat::params
#
# This repo sets defaults for use with the redhat
# OS family repo classes.
#
class openstack_extras::repo::redhat::params {
  $release = 'yoga'

  $centos_mirror_url = 'http://mirror.stream.centos.org'

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
