# == Class: openstack_extras::pacemaker::service
#
# Configures Pacemaker resource for a specified service and
# overrides its service provider to Pacemaker.
# Assumes there is a service already exists in the Puppet catalog.
# For example, the one, such as nova-api, heat-engine, neutron-agent-l3
# and so on, created by other core Puppet modules for Openstack.
#
# === Parameters
#
# [*ensure*]
#   (optional) The state of the service provided by Pacemaker
#   Defaults to present
#
# [*ocf_root_path*]
#   (optional) The path for OCF scripts
#   Defaults to /usr/lib/ocf
#
# [*primitive_class*]
#   (optional) The class of Pacemaker resource (primitive)
#   Defaults to ocf
#
# [*primitive_provider*]
#   (optional) The provider of OCF scripts
#   Defaults to pacemaker
#
# [*primitive_type*]
#   (optional) The type of the primitive (OCF file name).
#   Used with the other parameters as a full path to OCF script:
#   primitive_class/primitive_provider/primitive_type
#   resided at ocf_root_path/resource.d
#   Defaults to false
#
# [*parameters*]
#   (optional) The hash of parameters for a primitive
#   Defaults to false
#
# [*operations*]
#   (optional) The hash of operations for a primitive
#   Defaults to false
#
# [*metadata*]
#   (optional) The hash of metadata for a primitive
#   Defaults to false
#
# [*ms_metadata*]
#   (optional) The hash of ms_metadata for a primitive
#   Defaults to false
#
# [*use_handler*]
#   (optional) The handler (wrapper script) for OCF script
#   Could be useful for debug and informational purposes.
#   It sets some default values like OCF_ROOT in order to
#   simplify debugging of OCF scripts
#   Defaults to true
#
# [*handler_root_path*]
#   (optional) The path for a handler script
#   Defaults to /usr/local/bin
#
# [*ocf_script_template*]
#   (optional) ERB template for OCF script for Pacemaker
#   resource
#   Defaults to false
#
# [*ocf_script_file*]
#   (optional) OCF file for Pacemaker resource
#   Defaults to false
#
# [*create_primitive*]
#   (optional) Controls Pacemaker primitive creation
#   Defaults to true
#
# [*clone*]
#   (optional) Create a cloned primitive
#   Defaults to false
#
# === Examples
#
#  Will create resource and ensure Pacemaker provider for
#  'some-api-service' with the given OCF scripte template and
#  parameters:
#
#  $metadata = {
#    'resource-stickiness' => '1'
#  }
#  $operations = {
#    'monitor'  => {
#      'interval' => '20',
#      'timeout'  => '30',
#    },
#    'start'    => {
#      'timeout' => '60',
#    },
#    'stop'     => {
#      'timeout' => '60',
#    },
#  }
#  $ms_metadata = {
#    'interleave' => true,
#  }
#
#  openstack_extras::pacemaker::service { 'some-api-service' :
#    primitive_type      => 'some-api-service',
#    metadata            => $metadata,
#    ms_metadata         => $ms_metadata,
#    operations          => $operations,
#    clone               => true,
#    ocf_script_template => 'some_module/some_api_service.ocf.erb',
#  }
#
define openstack_extras::pacemaker::service (
  $ensure              = 'present',
  $ocf_root_path       = '/usr/lib/ocf',
  $primitive_class     = 'ocf',
  $primitive_provider  = 'pacemaker',
  $primitive_type      = false,
  $parameters          = false,
  $operations          = false,
  $metadata            = false,
  $ms_metadata         = false,
  $use_handler         = true,
  $handler_root_path   = '/usr/local/bin',
  $ocf_script_template = false,
  $ocf_script_file     = false,
  $create_primitive    = true,
  $clone               = false,
) {

  $service_name     = $title
  $primitive_name   = "p_${service_name}"
  $ocf_script_name  = "${service_name}-ocf-file"
  $ocf_handler_name = "ocf_handler_${service_name}"

  $ocf_dir_path     = "${ocf_root_path}/resource.d"
  $ocf_script_path  = "${ocf_dir_path}/${primitive_provider}/${$primitive_type}"
  $ocf_handler_path = "${handler_root_path}/${ocf_handler_name}"

  Service<| title == $service_name |> {
    provider   => 'pacemaker',
  }

  Service<| name == $service_name |> {
    provider   => 'pacemaker',
  }

  if $create_primitive {
    cs_primitive { $primitive_name :
      ensure          => $ensure,
      primitive_class => $primitive_class,
      primitive_type  => $primitive_type,
      provided_by     => $primitive_provider,
      parameters      => $parameters,
      operations      => $operations,
      metadata        => $metadata,
      ms_metadata     => $ms_metadata,
    }

    $clone_name="${primitive_name}-clone"
    if $clone {
      cs_clone { $clone_name :
        ensure    => present,
        primitive => $primitive_name,
        require   => Cs_primitive[$primitive_name]
      }
    }
    else {
      cs_clone { $clone_name :
        ensure  => absent,
        require => Cs_primitive[$primitive_name]
      }
    }
  }

  if $ocf_script_template or $ocf_script_file {
    file { $ocf_script_name :
      ensure  => $ensure,
      path    => $ocf_script_path,
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
    }

    if $ocf_script_template {
      File[$ocf_script_name] {
        content => template($ocf_script_template),
      }
    } elsif $ocf_script_file {
      File[$ocf_script_name] {
        source => "puppet:///modules/${ocf_script_file}",
      }
    }

  }

  if ($primitive_class == 'ocf') and ($use_handler) {
    file { $ocf_handler_name :
      ensure  => present,
      path    => $ocf_handler_path,
      owner   => 'root',
      group   => 'root',
      mode    => '0700',
      content => template('openstack_extras/ocf_handler.erb'),
    }
  }

  File<| title == $ocf_script_name |> ->
  Cs_primitive<| title == $primitive_name |>
  File<| title == $ocf_script_name |> ~> Service[$service_name]
  Cs_primitive<| title == $primitive_name |> -> Service[$service_name]
  File<| title == $ocf_handler_name |> -> Service[$service_name]

}
