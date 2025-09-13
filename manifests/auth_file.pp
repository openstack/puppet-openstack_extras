# == Class: openstack_extras::auth_file
#
# Creates an auth file that can be used to export
# environment variables that can be used to authenticate
# against a keystone server.
#
# === Parameters
#
# [*password*]
#   (Required) Password for this account as defined in keystone
#
# [*auth_url*]
#   (Optional) URL to authenticate against
#   Defaults to 'http://127.0.0.1:5000/v3/'
#
# [*service_token*]
#   (Optional) Keystone service token
#   NOTE: This setting will trigger a warning from keystone.
#   Authentication credentials will be ignored by keystone client
#   in favor of token authentication.
#   Defaults to undef.
#
# [*service_endpoint*]
#   (Optional) Keystone service endpoint
#   Defaults to 'http://127.0.0.1:5000/v3/'
#
# [*username*]
#   (Optional) Username for this account as defined in keystone
#   Defaults to 'admin'.
#
# [*project_name*]
#   (Optional) Project for this account as defined in keystone
#   Use instead of tenant_name for when using identity v3.
#   Defaults to 'openstack'.
#
# [*region_name*]
#   (Optional) Openstack region to use
#   Defaults to 'RegionOne'.
#
# [*use_no_cache*]
#   (Optional) Do not use the auth token cache.
#   Defaults to true.
#
# [*os_interface*]
#   (Optional) The common endpoint to use with OSC
#   Defaults to 'public'.
#
# [*os_endpoint_type*]
#   (Optional) The common endpoint to use with service-specific clients
#   Defaults to 'publicURL'.
#
# [*cinder_endpoint_type*]
#   (Optional) The Cinder endpoint to use
#   Defaults to 'publicURL'.
#
# [*glance_endpoint_type*]
#   (Optional) The Glance endpoint to use
#   Defaults to 'publicURL'.
#
# [*keystone_endpoint_type*]
#   (Optional) The Keystone endpoint to use
#   Defaults to 'publicURL'.
#
# [*nova_endpoint_type*]
#   (Optional) The Nova endpoint to use
#   Defaults to 'publicURL'.
#
# [*neutron_endpoint_type*]
#   (Optional) The Neutron endpoint to use
#   Defaults to 'publicURL'.
#
# [*auth_strategy*]
#   (Optional) The method to use for authentication
#   Defaults to 'keystone'.
#
# [*path*]
#   (Optional) File path
#   Defaults to '/root/openrc'.
#
# [*project_domain_name*]
#   (Optional) Project domain in v3 api.
#   Defaults to 'Default'.
#
# [*user_domain_name*]
#   (Optional) User domain in v3 api.
#   Defaults to 'Default'.
#
# [*auth_type*]
#   (Optional) Authentication type to load.
#   Default to undef.
#
# [*compute_api_version*]
#   (Optional) Compute API version to use.
#   Defaults to undef.
#
# [*network_api_version*]
#   (Optional) Network API version to use.
#   Defaults to undef.
#
# [*image_api_version*]
#   (Optional) Image API version to use.
#   Defaults to undef.
#
# [*volume_api_version*]
#   (Optional) Volume API version to use.
#   Defaults to undef.
#
# [*identity_api_version*]
#   (Optional) Identity API version to use.
#   Defaults to '3'.
#
# [*object_api_version*]
#   (Optional) Object API version to use.
#   Defaults to undef.
#
class openstack_extras::auth_file (
  String[1] $password,
  Stdlib::HTTPUrl $auth_url                                   = 'http://127.0.0.1:5000/v3/',
  Optional[String[1]] $service_token                          = undef,
  Stdlib::HTTPUrl $service_endpoint                           = 'http://127.0.0.1:5000/v3/',
  String[1] $username                                         = 'admin',
  String[1] $project_name                                     = 'openstack',
  String[1] $region_name                                      = 'RegionOne',
  Boolean $use_no_cache                                       = true,
  String[1] $project_domain_name                              = 'Default',
  String[1] $user_domain_name                                 = 'Default',
  Optional[String[1]] $auth_type                              = undef,
  Openstack_extras::EndpointType $os_interface                = 'public',
  Openstack_extras::EndpointType $os_endpoint_type            = 'publicURL',
  Openstack_extras::EndpointType $cinder_endpoint_type        = 'publicURL',
  Openstack_extras::EndpointType $glance_endpoint_type        = 'publicURL',
  Openstack_extras::EndpointType $keystone_endpoint_type      = 'publicURL',
  Openstack_extras::EndpointType $nova_endpoint_type          = 'publicURL',
  Openstack_extras::EndpointType $neutron_endpoint_type       = 'publicURL',
  String[1] $auth_strategy                                    = 'keystone',
  Stdlib::Absolutepath $path                                  = '/root/openrc',
  Optional[Openstack_extras::ApiVersion] $compute_api_version = undef,
  Optional[Openstack_extras::ApiVersion] $network_api_version = undef,
  Optional[Openstack_extras::ApiVersion] $image_api_version   = undef,
  Optional[Openstack_extras::ApiVersion] $volume_api_version  = undef,
  Openstack_extras::ApiVersion $identity_api_version          = 3,
  Optional[Openstack_extras::ApiVersion] $object_api_version  = undef,
) {
  file { $path:
    ensure    => file,
    owner     => 'root',
    group     => 'root',
    mode      => '0700',
    show_diff => false,
    tag       => ['openrc'],
    content   => template('openstack_extras/openrc.erb'),
  }
}
