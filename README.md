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
