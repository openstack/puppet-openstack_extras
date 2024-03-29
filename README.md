Team and repository tags
========================

[![Team and repository tags](https://governance.openstack.org/tc/badges/puppet-openstack_extras.svg)](https://governance.openstack.org/tc/reference/tags/index.html)

<!-- Change things from this point on -->

openstack_extras
================

#### Table of Contents

1. [Overview - What is the openstack_extras module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with openstack_extras](#setup)
4. [Implementation - An under-the-hood peek at what the module is doing](#implementation)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
7. [Release Notes - Release notes for the project](#release-notes)
8. [Contributors - Those with commits](#contributors)
9. [Repository - The project source code repository](#repository)

Overview
--------

The openstack_extras module is a part of [OpenStack](https://opendev.org/openstack),
an effort by the Openstack infrastructure team to provide continuous integration
testing and code review for Openstack and Openstack community projects as part
of the core software.  The module itself is used to add useful utilities for
composing and deploying OpenStack with the Openstack puppet modules.

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

    puppet module install openstack/openstack_extras

### Beginning with openstack_extras

Instructions for beginning with openstack_extras will be added later.

Implementation
--------------

### openstack_extras

openstack_extras is a combination of Puppet manifest and ruby code to delivery
configuration and extra functionality through types and providers.

**HA configuration for Openstack services**

This module allows to configure Openstack services in HA. Please refer to the [ha-guide](https://docs.openstack.org/ha-guide/) for details.
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

* https://docs.openstack.org/puppet-openstack-guide/latest/

Release Notes
-------------

* https://docs.openstack.org/releasenotes/puppet-openstack_extras

Contributors
------------

* https://github.com/openstack/puppet-openstack_extras/graphs/contributors

Repository
----------

* https://opendev.org/openstack/puppet-openstack_extras
