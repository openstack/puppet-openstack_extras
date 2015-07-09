##2015-07-08 - 6.0.0
###Summary

This is a backwards-incompatible major release for OpenStack Kilo.

####Backwards-incompatible changes
- repo: bump to Kilo by default

####Features
- Puppet 4.x support
- Add hash based repository management
- Add pacemaker provider for HA services
- Add auth file from openstack repo
- Support native OS primitive classes in Pacemaker
- Support cloned resources in Pacemaker
- auth_file: allow to change the path
- repo/redhat: manage EPEL with metalink instead of baseurl

####Bugfixes
- Ensure python-mysqldb is installed before MySQL db_sync
- Fix dependency on nova-common package

####Maintenance
- repo/apt: update to support apt 2.1.0 module
- Increase major bound on puppetlabs-apt

##2014-11-21 - 5.0.0
###Summary

Initial release for Juno.
