require 'spec_helper'

describe 'openstack_extras::auth_file' do

  describe "when only passing default class parameters" do

    let :params do
      { :password => 'admin' }
    end

    it 'should create a openrc file' do
      verify_contents(catalogue, '/root/openrc', [
        'export OS_NO_CACHE=\'true\'',
        'export OS_TENANT_NAME=\'openstack\'',
        'export OS_USERNAME=\'admin\'',
        'export OS_PASSWORD=\'admin\'',
        'export OS_AUTH_URL=\'http://127.0.0.1:5000/v2.0/\'',
        'export OS_AUTH_STRATEGY=\'keystone\'',
        'export OS_REGION_NAME=\'RegionOne\'',
        'export CINDER_ENDPOINT_TYPE=\'publicURL\'',
        'export GLANCE_ENDPOINT_TYPE=\'publicURL\'',
        'export KEYSTONE_ENDPOINT_TYPE=\'publicURL\'',
        'export NOVA_ENDPOINT_TYPE=\'publicURL\'',
        'export NEUTRON_ENDPOINT_TYPE=\'publicURL\''
      ])
    end
  end

  describe 'when overriding parameters' do

    let :params do
      {
        :password                 => 'admin',
        :auth_url                 => 'http://127.0.0.2:5000/v2.0/',
        :service_token            => 'servicetoken',
        :service_endpoint         => 'http://127.0.0.2:35357/v2.0/',
        :username                 => 'myuser',
        :tenant_name              => 'mytenant',
        :region_name              => 'myregion',
        :use_no_cache             => 'false',
        :cinder_endpoint_type     => 'internalURL',
        :glance_endpoint_type     => 'internalURL',
        :keystone_endpoint_type   => 'internalURL',
        :nova_endpoint_type       => 'internalURL',
        :neutron_endpoint_type    => 'internalURL',
        :auth_strategy            => 'no_auth',
      }
    end

    it 'should create a openrc file' do
      verify_contents(catalogue, '/root/openrc', [
        'export OS_SERVICE_TOKEN=\'servicetoken\'',
        'export OS_SERVICE_ENDPOINT=\'http://127.0.0.2:35357/v2.0/\'',
        'export OS_NO_CACHE=\'false\'',
        'export OS_TENANT_NAME=\'mytenant\'',
        'export OS_USERNAME=\'myuser\'',
        'export OS_PASSWORD=\'admin\'',
        'export OS_AUTH_URL=\'http://127.0.0.2:5000/v2.0/\'',
        'export OS_AUTH_STRATEGY=\'no_auth\'',
        'export OS_REGION_NAME=\'myregion\'',
        'export CINDER_ENDPOINT_TYPE=\'internalURL\'',
        'export GLANCE_ENDPOINT_TYPE=\'internalURL\'',
        'export KEYSTONE_ENDPOINT_TYPE=\'internalURL\'',
        'export NOVA_ENDPOINT_TYPE=\'internalURL\'',
        'export NEUTRON_ENDPOINT_TYPE=\'internalURL\''
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
end
