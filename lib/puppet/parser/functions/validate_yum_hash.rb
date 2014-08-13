module Puppet::Parser::Functions

  yumrepo_arguments = [
    'name',
    'ensure',
    'baseurl',
    'cost',
    'descr',
    'enabled',
    'enablegroups',
    'exclude',
    'failovermethod',
    'gpgcheck',
    'gpgkey',
    'http_caching',
    'include',
    'includepkgs',
    'keepalive',
    'metadata_expire',
    'metalink',
    'mirrorlist',
    'priority',
    'protect',
    'provider',
    'proxy',
    'proxy_password',
    'proxy_username',
    'repo_gpgcheck',
    's3_enabled',
    'skip_if_unavailable',
    'sslcacert',
    'sslclientcert',
    'sslclientkey',
    'sslverify',
    'target',
    'timeout'
  ]

  newfunction(:validate_yum_hash) do |args|
    if args.size > 1
      raise Puppet::Error, "validate_yum_hash takes only a single argument, #{args.size} provided"
    end
    arg = args[0]

    if not arg.kind_of?(Hash)
      raise Puppet::Error, "non-hash argument provided to validate_yum_hash"
    end

    if arg.size > 0
      arg.each do |title, params|
        params.each do |param, value|
          if ! yumrepo_arguments.include?(param)
            raise Puppet::Error, "Parameter #{param} is not valid for the yumrepo type"
          end
        end
      end
    end
  end
end
