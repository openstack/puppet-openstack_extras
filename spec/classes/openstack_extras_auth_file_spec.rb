require 'spec_helper'

describe 'openstack_extras::auth_file' do

  describe "when only passing default class parameters" do

    let :params do
      { :password => 'admin' }
    end

    it 'should create a openrc file' do
      verify_contents(catalogue, '/root/openrc', [
        'export OS_NO_CACHE=\'true\'',
        'export OS_PROJECT_NAME=\'openstack\'',
        'export OS_USERNAME=\'admin\'',
        'export OS_PASSWORD=\'admin\'',
        'export OS_AUTH_URL=\'http://127.0.0.1:5000/v3/\'',
        'export OS_AUTH_STRATEGY=\'keystone\'',
        'export OS_REGION_NAME=\'RegionOne\'',
        'export OS_PROJECT_DOMAIN_NAME=\'default\'',
        'export OS_USER_DOMAIN_NAME=\'default\'',
        'export CINDER_ENDPOINT_TYPE=\'publicURL\'',
        'export GLANCE_ENDPOINT_TYPE=\'publicURL\'',
        'export KEYSTONE_ENDPOINT_TYPE=\'publicURL\'',
        'export NOVA_ENDPOINT_TYPE=\'publicURL\'',
        'export NEUTRON_ENDPOINT_TYPE=\'publicURL\'',
        'export OS_IDENTITY_API_VERSION=\'3\'',
      ])
    end
  end

  describe 'when overriding parameters' do

    let :params do
      {
        :password                 => 'admin',
        :auth_url                 => 'http://127.0.0.2:5000/v3/',
        :service_token            => 'servicetoken',
        :service_endpoint         => 'http://127.0.0.2:35357/v3/',
        :username                 => 'myuser',
        :tenant_name              => 'mytenant',
        :project_name             => 'myproject',
        :region_name              => 'myregion',
        :use_no_cache             => 'false',
        :cinder_endpoint_type     => 'internalURL',
        :glance_endpoint_type     => 'internalURL',
        :keystone_endpoint_type   => 'internalURL',
        :nova_endpoint_type       => 'internalURL',
        :neutron_endpoint_type    => 'internalURL',
        :auth_strategy            => 'no_auth',
        :user_domain              => 'anotherdomain',
        :project_domain           => 'anotherdomain',
        :identity_api_version     => '3.1',
      }
    end

    it 'should create a openrc file' do
      verify_contents(catalogue, '/root/openrc', [
        'export OS_SERVICE_TOKEN=\'servicetoken\'',
        'export OS_SERVICE_ENDPOINT=\'http://127.0.0.2:35357/v3/\'',
        'export OS_NO_CACHE=\'false\'',
        'export OS_TENANT_NAME=\'mytenant\'',
        'export OS_PROJECT_NAME=\'myproject\'',
        'export OS_USERNAME=\'myuser\'',
        'export OS_PASSWORD=\'admin\'',
        'export OS_AUTH_URL=\'http://127.0.0.2:5000/v3/\'',
        'export OS_AUTH_STRATEGY=\'no_auth\'',
        'export OS_REGION_NAME=\'myregion\'',
        'export OS_PROJECT_DOMAIN_NAME=\'anotherdomain\'',
        'export OS_USER_DOMAIN_NAME=\'anotherdomain\'',
        'export CINDER_ENDPOINT_TYPE=\'internalURL\'',
        'export GLANCE_ENDPOINT_TYPE=\'internalURL\'',
        'export KEYSTONE_ENDPOINT_TYPE=\'internalURL\'',
        'export NOVA_ENDPOINT_TYPE=\'internalURL\'',
        'export NEUTRON_ENDPOINT_TYPE=\'internalURL\'',
        'export OS_IDENTITY_API_VERSION=\'3.1\'',
      ])
    end
  end

  describe "handle password and token with single quotes" do

    let :params do
      {
        :password             => 'singlequote\'',
        :service_token        => 'key\'stone'
      }
    end

    it 'should create a openrc file' do
      verify_contents(catalogue, '/root/openrc', [
        'export OS_SERVICE_TOKEN=\'key\\\'stone\'',
        'export OS_PASSWORD=\'singlequote\\\'\'',
      ])
    end
  end

  describe "when the file is in /tmp" do

    let :params do
      {
        :password => 'secret',
        :path     => '/tmp/openrc'
      }
    end

   it { is_expected.to contain_file('/tmp/openrc')}
  end
end
