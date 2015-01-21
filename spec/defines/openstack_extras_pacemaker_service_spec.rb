require 'spec_helper'

describe 'openstack_extras::pacemaker::service', :type => :define do

  let :pre_condition do
    "class { 'foo': }"
  end

  let (:title) { 'foo-api' }

  let :default_params do
    {
        :ensure => 'present',
        :ocf_root_path => '/usr/lib/ocf',
        :primitive_class => 'ocf',
        :primitive_provider => 'pacemaker',
        :primitive_type => false,
        :parameters => false,
        :operations => false,
        :metadata => false,
        :ms_metadata => false,
        :use_handler => true,
        :handler_root_path => '/usr/local/bin',
        :ocf_script_template => false,
        :ocf_script_file => false,
        :create_primitive => true,
        :clone => false
    }
  end

  context 'with defaults' do
    it 'should contain openstack_extras::pacemaker::service definition' do
      should contain_openstack_extras__pacemaker__service(title).with(default_params)
    end

    it 'should override existing service provider' do
      should contain_service('foo-api').with(
                 {
                     :provider => 'pacemaker'
                 })
    end

    it 'should create a pacemaker primitive' do
      should contain_cs_primitive('p_foo-api').with(
                 {
                     'ensure' => default_params[:ensure],
                     'primitive_class' => default_params[:primitive_class],
                     'primitive_type' => default_params[:primitive_type],
                     'provided_by' => default_params[:primitive_provider],
                     'parameters' => default_params[:parameters],
                     'operations' => default_params[:operations],
                     'metadata' => default_params[:metadata],
                     'ms_metadata' => default_params[:ms_metadata],
                 })
    end
    it 'should not create a cloned resource' do
      should contain_cs_clone('p_foo-api-clone').with(
                 {
                     'ensure' => 'absent',
                 })
    end
  end

  context 'with custom OCF file' do
    let :params do
      default_params.merge(
          {
              :ocf_script_file => 'foo/scripts/foo.ocf'
          }
      )
    end
    let (:ocf_dir_path) { "#{params[:ocf_root_path]}/resource.d" }
    let (:ocf_script_path) { "#{ocf_dir_path}/#{params[:primitive_provider]}/#{params[:primitive_type]}" }
    let (:ocf_handler_name) { "ocf_handler_#{title}" }
    let (:ocf_handler_path) { "#{params[:handler_root_path]}/#{ocf_handler_name}" }

    it 'should create an OCF file' do
      should contain_file("#{title}-ocf-file").with(
                 {
                     'ensure' => 'present',
                     'path' => ocf_script_path,
                     'mode' => '0755',
                     'owner' => 'root',
                     'group' => 'root',
                     'source' => "puppet:///modules/#{params[:ocf_script_file]}"
                 })
    end

    it 'should create a handler file' do
      should contain_file("#{ocf_handler_name}").with(
                 {
                     'ensure' => 'present',
                     'path' => ocf_handler_path,
                     'owner' => 'root',
                     'group' => 'root',
                     'mode' => '0700',
                 }).with_content(/OCF_ROOT/)
    end

  end

  context 'with custom OCF path, provider, erb and w/o a wrapper' do
    let(:params) do
      default_params.merge(
          {
              :ocf_script_template => 'foo/foo.ocf.erb',
              :use_handler => false,
              :primitive_provider => 'some_provider',
              :ocf_root_path => '/usr/lib/some_path',
          })
    end
    let (:ocf_dir_path) { "#{params[:ocf_root_path]}/resource.d" }
    let (:ocf_script_path) {
      "#{ocf_dir_path}/#{params[:primitive_provider]}/#{params[:primitive_type]}"
    }

    it 'should create an OCF file from template' do
      should contain_file("#{title}-ocf-file").with(
                 {
                     'path' => ocf_script_path,
                     'mode' => '0755',
                     'owner' => 'root',
                     'group' => 'root'
                 }).with_content(/erb/)
    end

    it 'should not create a handler file' do
      should_not contain_file("#{params[:ocf_handler_name]}")
    end

    it 'should create a pacemaker primitive' do
      should contain_cs_primitive('p_foo-api').with(
                 {
                     'ensure' => params[:ensure],
                     'primitive_class' => params[:primitive_class],
                     'primitive_type' => params[:primitive_type],
                     'provided_by' => params[:primitive_provider],
                     'parameters' => params[:parameters],
                     'operations' => params[:operations],
                     'metadata' => params[:metadata],
                     'ms_metadata' => params[:ms_metadata],
                 })
    end
  end

  context 'with cloned resources' do
    let (:params) do
      default_params.merge(
          {
              :clone => true,
          })
    end
    it 'should create a cloned resource' do
      should contain_cs_clone('p_foo-api-clone').with(
                 {
                     'ensure'    => 'present',
                     'primitive' => 'p_foo-api',
                 })
    end
  end

end
