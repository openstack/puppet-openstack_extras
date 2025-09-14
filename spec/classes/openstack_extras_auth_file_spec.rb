require 'spec_helper'

describe 'openstack_extras::auth_file' do
  shared_examples 'openstack_extras::auth_file' do
    context 'when only passing default class parameters' do
      let :params do
        {
          :password => 'admin'
        }
      end

      it { is_expected.to contain_file('/root/openrc').with(
        :ensure    => 'file',
        :owner     => 'root',
        :group     => 'root',
        :mode      => '0700',
        :show_diff => false,
        :tag       => ['openrc'],
        :content   => <<EOS
#!/bin/sh
export OS_NO_CACHE='true'
export OS_PROJECT_NAME='openstack'
export OS_USERNAME='admin'
export OS_PASSWORD='admin'
export OS_AUTH_URL='http://127.0.0.1:5000/v3/'
export OS_AUTH_STRATEGY='keystone'
export OS_REGION_NAME='RegionOne'
export OS_PROJECT_DOMAIN_NAME='Default'
export OS_USER_DOMAIN_NAME='Default'
export OS_INTERFACE='public'
export OS_ENDPOINT_TYPE='publicURL'
export CINDER_ENDPOINT_TYPE='publicURL'
export GLANCE_ENDPOINT_TYPE='publicURL'
export KEYSTONE_ENDPOINT_TYPE='publicURL'
export NOVA_ENDPOINT_TYPE='publicURL'
export NEUTRON_ENDPOINT_TYPE='publicURL'
export OS_IDENTITY_API_VERSION='3'
EOS
      )}
    end

    context 'when overriding parameters' do
      let :params do
        {
          :password                 => 'admin',
          :auth_url                 => 'http://127.0.0.2:5000/v3/',
          :service_token            => 'servicetoken',
          :service_endpoint         => 'http://127.0.0.2:5000/v3/',
          :username                 => 'myuser',
          :project_name             => 'myproject',
          :region_name              => 'myregion',
          :use_no_cache             => 'false',
          :os_interface             => 'internal',
          :os_endpoint_type         => 'internalURL',
          :cinder_endpoint_type     => 'internalURL',
          :glance_endpoint_type     => 'internalURL',
          :keystone_endpoint_type   => 'internalURL',
          :nova_endpoint_type       => 'internalURL',
          :neutron_endpoint_type    => 'internalURL',
          :auth_strategy            => 'no_auth',
          :path                     => '/path/to/file',
          :user_domain_name         => 'anotherdomain',
          :project_domain_name      => 'anotherdomain',
          :compute_api_version      => '2.1',
          :network_api_version      => '2.0',
          :image_api_version        => '2',
          :volume_api_version       => '2',
          :identity_api_version     => '3.1',
          :object_api_version       => '1',
        }
      end

      it { is_expected.to contain_file('/path/to/file').with(
        :ensure    => 'file',
        :owner     => 'root',
        :group     => 'root',
        :mode      => '0700',
        :show_diff => false,
        :tag       => ['openrc'],
        :content   => <<EOS
#!/bin/sh
export OS_SERVICE_TOKEN='servicetoken'
export OS_SERVICE_ENDPOINT='http://127.0.0.2:5000/v3/'
export OS_NO_CACHE='false'
export OS_PROJECT_NAME='myproject'
export OS_USERNAME='myuser'
export OS_PASSWORD='admin'
export OS_AUTH_URL='http://127.0.0.2:5000/v3/'
export OS_AUTH_STRATEGY='no_auth'
export OS_REGION_NAME='myregion'
export OS_PROJECT_DOMAIN_NAME='anotherdomain'
export OS_USER_DOMAIN_NAME='anotherdomain'
export OS_INTERFACE='internal'
export OS_ENDPOINT_TYPE='internalURL'
export CINDER_ENDPOINT_TYPE='internalURL'
export GLANCE_ENDPOINT_TYPE='internalURL'
export KEYSTONE_ENDPOINT_TYPE='internalURL'
export NOVA_ENDPOINT_TYPE='internalURL'
export NEUTRON_ENDPOINT_TYPE='internalURL'
export OS_COMPUTE_API_VERSION='2.1'
export OS_NETWORK_API_VERSION='2.0'
export OS_IMAGE_API_VERSION='2'
export OS_VOLUME_API_VERSION='2'
export OS_IDENTITY_API_VERSION='3.1'
export OS_OBJECT_API_VERSION='1'
EOS
      )}
    end

    context 'handle password and token with single quotes' do
      let :params do
        {
          :password      => 'singlequote\'',
          :service_token => 'key\'stone'
        }
      end

      it { is_expected.to contain_file('/root/openrc').with(
        :ensure    => 'file',
        :owner     => 'root',
        :group     => 'root',
        :mode      => '0700',
        :show_diff => false,
        :tag       => ['openrc'],
        :content   => <<EOS
#!/bin/sh
export OS_SERVICE_TOKEN='key\\'stone'
export OS_SERVICE_ENDPOINT='http://127.0.0.1:5000/v3/'
export OS_NO_CACHE='true'
export OS_PROJECT_NAME='openstack'
export OS_USERNAME='admin'
export OS_PASSWORD='singlequote\\''
export OS_AUTH_URL='http://127.0.0.1:5000/v3/'
export OS_AUTH_STRATEGY='keystone'
export OS_REGION_NAME='RegionOne'
export OS_PROJECT_DOMAIN_NAME='Default'
export OS_USER_DOMAIN_NAME='Default'
export OS_INTERFACE='public'
export OS_ENDPOINT_TYPE='publicURL'
export CINDER_ENDPOINT_TYPE='publicURL'
export GLANCE_ENDPOINT_TYPE='publicURL'
export KEYSTONE_ENDPOINT_TYPE='publicURL'
export NOVA_ENDPOINT_TYPE='publicURL'
export NEUTRON_ENDPOINT_TYPE='publicURL'
export OS_IDENTITY_API_VERSION='3'
EOS
      )}
    end

    context 'when the file is in /tmp' do
      let :params do
        {
          :password => 'secret',
          :path     => '/tmp/openrc'
        }
      end

      it { should contain_file('/tmp/openrc')}
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      it_behaves_like 'openstack_extras::auth_file'
    end
  end
end
