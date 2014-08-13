# == Class: openstack_extras::repo::redhat::params
#
# This repo sets defaults for use with the redhat
# osfamily repo classes.
#
class openstack_extras::repo::redhat::params
{
  $release          = 'juno'

  $repo_defaults    = { 'enabled'    => '1',
                        'gpgcheck'   => '1',
                        'notify'     => "Exec[yum_refresh]",
                        'mirrorlist' => 'absent',
                        'require'    => "Anchor[openstack_extras_redhat]"
                      }

  $gpgkey_defaults  = { 'owner' => 'root',
                        'group' => 'root',
                        'mode' => '0644',
                        'before' => "Anchor[openstack_extras_redhat]"
                      }

  case $::operatingsystem {
    centos, redhat, scientific, slc: { $dist = 'epel' }
    fedora: { $dist = 'fedora' }
    default: {
      warning('Unrecognised operatingsystem')
    }
  }

  $rdo_priority = 98
}
