require 'spec_helper'

describe 'openstack_extras::pacemaker::service', :type => :define do
  shared_examples 'openstack_extras::pacemaker::service' do
    let :pre_condition do
      [
        "class { 'glance::api::authtoken': password => 'password', }",
        "include glance::api",
      ]
    end

    let (:title) { 'glance-api' }

    let :default_params do
      {
        :ensure              => 'present',
        :ocf_root_path       => '/usr/lib/ocf',
        :primitive_class     => 'ocf',
        :primitive_provider  => 'pacemaker',
        :primitive_type      => false,
        :parameters          => false,
        :operations          => false,
        :metadata            => false,
        :ms_metadata         => false,
        :use_handler         => true,
        :handler_root_path   => '/usr/local/bin',
        :ocf_script_template => false,
        :ocf_script_file     => false,
        :create_primitive    => true,
        :clone               => false
      }
    end

    context 'with defaults' do
      it { should contain_openstack_extras__pacemaker__service(title).with(default_params) }
      it { should contain_service('glance-api').with_provider('pacemaker') }

      it { should contain_cs_primitive('p_glance-api').with(
        :ensure          => default_params[:ensure],
        :primitive_class => default_params[:primitive_class],
        :primitive_type  => default_params[:primitive_type],
        :provided_by     => default_params[:primitive_provider],
        :parameters      => default_params[:parameters],
        :operations      => default_params[:operations],
        :metadata        => default_params[:metadata],
        :ms_metadata     => default_params[:ms_metadata],
      )}

      it { should contain_cs_clone('p_glance-api-clone').with_ensure('absent') }
    end

    context 'with custom OCF file' do
      let :params do
        default_params.merge( :ocf_script_file => 'foo/scripts/foo.ocf' )
      end

      let (:ocf_dir_path) { "#{params[:ocf_root_path]}/resource.d" }
      let (:ocf_script_path) { "#{ocf_dir_path}/#{params[:primitive_provider]}/#{params[:primitive_type]}" }
      let (:ocf_handler_name) { "ocf_handler_#{title}" }
      let (:ocf_handler_path) { "#{params[:handler_root_path]}/#{ocf_handler_name}" }

      it { should contain_file("#{title}-ocf-file").with(
        :ensure => 'present',
        :path   => ocf_script_path,
        :mode   => '0755',
        :owner  => 'root',
        :group  => 'root',
        :source => "puppet:///modules/#{params[:ocf_script_file]}"
      )}

      it { should contain_file("#{ocf_handler_name}").with(
        :ensure  => 'present',
        :path    => ocf_handler_path,
        :owner   => 'root',
        :group   => 'root',
        :mode    => '0700',
        :content => /OCF_ROOT/
      )}
    end

    context 'with custom OCF path, provider, erb and w/o a wrapper' do
      let(:params) do
        default_params.merge( :ocf_script_template => 'openstack_extras/ocf_handler.erb',
                              :use_handler         => false,
                              :primitive_provider  => 'some_provider',
                              :ocf_root_path       => '/usr/lib/some_path' )
      end

      let (:ocf_dir_path) { "#{params[:ocf_root_path]}/resource.d" }
      let (:ocf_script_path) {
        "#{ocf_dir_path}/#{params[:primitive_provider]}/#{params[:primitive_type]}"
      }

      it { should contain_file("#{title}-ocf-file").with(
        :path    => ocf_script_path,
        :mode    => '0755',
        :owner   => 'root',
        :group   => 'root',
        :content => /monitor/
      )}

      it { should_not contain_file('ocf_handler_glance_api') }

      it { should contain_cs_primitive('p_glance-api').with(
        :ensure          => params[:ensure],
        :primitive_class => params[:primitive_class],
        :primitive_type  => params[:primitive_type],
        :provided_by     => params[:primitive_provider],
        :parameters      => params[:parameters],
        :operations      => params[:operations],
        :metadata        => params[:metadata],
        :ms_metadata     => params[:ms_metadata],
      )}
    end

    context 'with cloned resources' do
      let (:params) do
        default_params.merge( :clone => true )
      end

      it { should contain_cs_clone('p_glance-api-clone').with(
        :ensure    => 'present',
        :primitive => 'p_glance-api',
      )}
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      if facts[:osfamily] == 'Debian' and facts[:operatingsystem] == 'Debian'
        it_behaves_like 'openstack_extras::pacemaker::service'
      end
    end
  end
end
