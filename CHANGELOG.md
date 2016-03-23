## 8.0.0 and beyond

From 8.0.0 release and beyond, release notes are published on
[docs.openstack.org](http://docs.openstack.org/releasenotes/puppet-openstack_extras/).

##2015-11-24 - 7.0.0
###Summary

This is a backwards-incompatible major release for OpenStack Liberty.

####Backwards-incompatible changes
- repo: bump to Liberty by default

####Features
- repo/ubuntu: allow to change uca repo name

####Maintenance
- implement acceptance tests
- try to use zuul-cloner to prepare fixtures
- remove class_parameter_defaults puppet-lint check
- acceptance: use common bits from puppet-openstack-integration
- fix RSpec 3.x syntax
- initial msync run for all Puppet OpenStack modules

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
