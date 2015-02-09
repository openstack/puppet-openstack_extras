openstack_extras
============

5.0.0 - 2014.2.0 - Juno

#### Table of Contents

1. [Overview - What is the openstack_extras module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with openstack_extras](#setup)
4. [Implementation - An under-the-hood peek at what the module is doing](#implementation)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
7. [Contributors - Those with commits](#contributors)
8. [Release Notes - Notes on the most recent updates to the module](#release-notes)

Overview
--------

The openstack_extras module is a part of [Stackforge](https://github.com/stackforge),
an effort by the Openstack infrastructure team to provide continuous integration
testing and code review for Openstack and Openstack community projects not part
of the core software.  The module itself is used to add useful utilities for
composing and deploying OpenStack with the Stackforge Openstack modules.

Module Description
------------------

The openstack_extras module is intended to provide useful utilities to help
with OpenStack deployments, including composition classes, HA utilities,
monitoring functionality, and so on.

This module combines other modules in order to build and leverage an entire
OpenStack software stack. This module replaces functionality from the
deprecated [stackforge/puppet-openstack module](https://github.com/stackforge/puppet-openstack).

Setup
-----

### Installing openstack_extras

    example% puppet module install puppetlabs/openstack_extras

### Beginning with openstack_extras

Instructions for beginning with openstack_extras will be added later.

Implementation
--------------

### openstack_extras

openstack_extras is a combination of Puppet manifest and ruby code to delivery
configuration and extra functionality through types and providers.

**HA configuration for Openstack services**

This module allows to configure Openstack services in HA. Please refer to the [ha-guide](http://docs.openstack.org/high-availability-guide/content/index.html) for details.
If you have a Corosync with Pacemaker cluster with several nodes joined, you may want to use an HA service provider which allows you to create the pacemaker resources for Openstack services and run them in HA mode.
The example HA service configuration for keystone service:

```puppet
openstack_extras::pacemaker::service { 'openstack-keystone' :
    ensure             => present,
    metadata           => {},
    ms_metadata        => {},
    operations         => {},
    parameters         => {},
    primitive_class    => 'systemd',
    primitive_provider => false,
    primitive_type     => 'openstack-keystone',
    use_handler        => false,
    clone              => true,
    require            => Package['openstack-keystone']
}
```
This example will create a pacemaker clone resource named `p_openstack-keystone-clone` and will start it with the help of systemd.

And this example will create a resource `p_cinder-api-clone` for Cinder API service with the given OCF script template from some `cluster` module:

```puppet
  $metadata = {
    'resource-stickiness' => '1'
  }
  $operations = {
    'monitor'  => {
      'interval' => '20',
      'timeout'  => '30',
    },
    'start'    => {
      'timeout' => '60',
    },
    'stop'     => {
      'timeout' => '60',
    },
  }
  $ms_metadata = {
    'interleave' => true,
  }

  openstack_extras::pacemaker::service { 'cinder-api' :
    primitive_type      => 'cinder-api',
    metadata            => $metadata,
    ms_metadata         => $ms_metadata,
    operations          => $operations,
    clone               => true,
    ocf_script_template => 'cluster/cinder_api.ocf.erb',
  }

```

Limitations
-----------

* Limitations will be added as they are discovered.

Development
-----------

Developer documentation for the entire puppet-openstack project.

* https://wiki.openstack.org/wiki/Puppet-openstack#Developer_documentation

Contributors
------------

* https://github.com/stackforge/puppet-openstack_extras/graphs/contributors

Versioning
----------

This module has been given version 5 to track the puppet-openstack modules. The
versioning for the puppet-openstack modules are as follows:

```
Puppet Module :: OpenStack Version :: OpenStack Codename
2.0.0         -> 2013.1.0          -> Grizzly
3.0.0         -> 2013.2.0          -> Havana
4.0.0         -> 2014.1.0          -> Icehouse
5.0.0         -> 2014.2.0          -> Juno
```

Release Notes
-------------

**5.0.0**

* This is the initial release of this module.
