require 'spec_helper'

describe Puppet::Type.type(:service).provider(:pacemaker) do

  let(:resource) { Puppet::Type.type(:service).new(:name => title,  :provider=> :pacemaker) }
  let(:provider) { resource.provider }
  let(:title) { 'myservice' }
  let(:full_name) { 'clone-p_myservice' }
  let(:name) { 'p_myservice' }
  let(:hostname) { 'mynode' }
  let(:primitive_class) { 'ocf' }

  before :each do
    @class = provider

    allow(@class).to receive(:title).and_return(title)
    allow(@class).to receive(:hostname).and_return(hostname)
    allow(@class).to receive(:name).and_return(name)
    allow(@class).to receive(:full_name).and_return(full_name)
    allow(@class).to receive(:basic_service_name).and_return(title)
    allow(@class).to receive(:primitive_class).and_return(primitive_class)

    allow(@class).to receive(:cib_reset).and_return(true)

    allow(@class).to receive(:wait_for_online).and_return(true)
    allow(@class).to receive(:wait_for_status).and_return(true)
    allow(@class).to receive(:wait_for_start).and_return(true)
    allow(@class).to receive(:wait_for_stop).and_return(true)

    allow(@class).to receive(:disable_basic_service).and_return(true)
    allow(@class).to receive(:get_primitive_puppet_status).and_return(:started)
    allow(@class).to receive(:get_primitive_puppet_enable).and_return(:true)

    allow(@class).to receive(:primitive_is_managed?).and_return(true)
    allow(@class).to receive(:primitive_is_running?).and_return(true)
    allow(@class).to receive(:primitive_has_failures?).and_return(false)
    allow(@class).to receive(:primitive_is_complex?).and_return(false)
    allow(@class).to receive(:primitive_is_multistate?).and_return(false)
    allow(@class).to receive(:primitive_is_clone?).and_return(false)

    allow(@class).to receive(:unban_primitive).and_return(true)
    allow(@class).to receive(:ban_primitive).and_return(true)
    allow(@class).to receive(:start_primitive).and_return(true)
    allow(@class).to receive(:stop_primitive).and_return(true)
    allow(@class).to receive(:cleanup_primitive).and_return(true)
    allow(@class).to receive(:enable).and_return(true)
    allow(@class).to receive(:disable).and_return(true)

    allow(@class).to receive(:constraint_location_add).and_return(true)
    allow(@class).to receive(:constraint_location_remove).and_return(true)

    allow(@class).to receive(:get_cluster_debug_report).and_return(true)
  end

  context 'service name mangling' do
    it 'uses title as the service name if it is found in CIB' do
      allow(@class).to receive(:name).and_call_original
      allow(@class).to receive(:primitive_exists?).with(title).and_return(true)
      expect(@class.name).to eq(title)
    end

    it 'uses "p_" prefix with name if found name with prefix' do
      allow(@class).to receive(:name).and_call_original
      allow(@class).to receive(:primitive_exists?).with(title).and_return(false)
      allow(@class).to receive(:primitive_exists?).with(name).and_return(true)
      expect(@class.name).to eq(name)
    end

    it 'uses name without "p_" to disable basic service' do
      allow(@class).to receive(:name).and_return(name)
      expect(@class.basic_service_name).to eq(title)
    end
  end

  context '#status' do
    it 'should wait for pacemaker to become online' do
      expect(@class).to receive(:wait_for_online)
      @class.status
    end

    it 'should reset cib mnemoization on every call' do
      expect(@class).to receive(:cib_reset)
      @class.status
    end

    it 'gets service status locally' do
      expect(@class).to receive(:get_primitive_puppet_status).with name, hostname
      @class.status
    end

  end

  context '#start' do
    it 'tries to enable service if it is not enabled to work with it' do
      allow(@class).to receive(:primitive_is_managed?).and_return(false)
      expect(@class).to receive(:enable).once
      @class.start
      allow(@class).to receive(:primitive_is_managed?).and_return(true)
      allow(@class).to receive(:enable).and_call_original
      expect(@class).to receive(:enable).never
      @class.start
    end

    it 'tries to disable a basic service with the same name' do
      expect(@class).to receive(:disable_basic_service)
      @class.start
    end

    it 'should cleanup a primitive' do
      allow(@class).to receive(:primitive_has_failures?).and_return(true)
      expect(@class).to receive(:cleanup_primitive).with(full_name, hostname).once
      @class.start
    end

    it 'tries to unban the service on the node by the name' do
      expect(@class).to receive(:unban_primitive).with(name, hostname)
      @class.start
    end

    it 'tries to start the service by its full name' do
      expect(@class).to receive(:start_primitive).with(full_name)
      @class.start
    end

    it 'adds a location constraint for the service by its full_name' do
      expect(@class).to receive(:constraint_location_add).with(full_name, hostname)
      @class.start
    end

    it 'waits for the service to start locally if primitive is clone' do
      allow(@class).to receive(:primitive_is_clone?).and_return(true)
      allow(@class).to receive(:primitive_is_multistate?).and_return(false)
      allow(@class).to receive(:primitive_is_complex?).and_return(true)
      expect(@class).to receive(:wait_for_start).with name
      @class.start
    end

    it 'waits for the service to start master anywhere if primitive is multistate' do
      allow(@class).to receive(:primitive_is_clone?).and_return(false)
      allow(@class).to receive(:primitive_is_multistate?).and_return(true)
      allow(@class).to receive(:primitive_is_complex?).and_return(true)
      expect(@class).to receive(:wait_for_master).with name
      @class.start
    end

    it 'waits for the service to start anywhere if primitive is simple' do
      allow(@class).to receive(:primitive_is_clone?).and_return(false)
      allow(@class).to receive(:primitive_is_multistate?).and_return(false)
      allow(@class).to receive(:primitive_is_complex?).and_return(false)
      expect(@class).to receive(:wait_for_start).with name
      @class.start
    end
  end

  context '#stop' do
    it 'tries to disable service if it is not enabled to work with it' do
      allow(@class).to receive(:primitive_is_managed?).and_return(false)
      expect(@class).to receive(:enable).once
      @class.stop
      allow(@class).to receive(:primitive_is_managed?).and_return(true)
      allow(@class).to receive(:enable).and_call_original
      expect(@class).to receive(:enable).never
      @class.stop
    end

    it 'should cleanup a primitive on stop' do
      expect(@class).to receive(:cleanup_primitive).with(full_name, hostname).once.once
      @class.stop
    end

    it 'uses Ban to stop the service and waits for it to stop locally if service is complex' do
      allow(@class).to receive(:primitive_is_complex?).and_return(true)
      expect(@class).to receive(:wait_for_stop).with name, hostname
      expect(@class).to receive(:ban_primitive).with name, hostname
      @class.stop
    end

    it 'uses Stop to stop the service and waits for it to stop globally if service is simple' do
      allow(@class).to receive(:primitive_is_complex?).and_return(false)
      expect(@class).to receive(:wait_for_stop).with name
      expect(@class).to receive(:stop_primitive).with name
      @class.stop
    end
  end

  context '#restart' do
    it 'does not stop or start the service if it is not locally running' do
      allow(@class).to receive(:primitive_is_running?).with(name, hostname).and_return(false)
      expect(@class).to receive(:stop).never
      expect(@class).to receive(:start).never
      @class.restart
    end

    it 'stops and start the service if it is locally running' do
      allow(@class).to receive(:primitive_is_running?).with(name, hostname).and_return(true)
      expect(@class).to receive(:stop).ordered
      expect(@class).to receive(:start).ordered
      @class.restart
    end
  end

  context 'basic service handling' do
    before :each do
      allow(@class).to receive(:disable_basic_service).and_call_original
      allow(@class.extra_provider).to receive(:enableable?).and_return true
      allow(@class.extra_provider).to receive(:enabled?).and_return :true
      allow(@class.extra_provider).to receive(:disable).and_return true
      allow(@class.extra_provider).to receive(:stop).and_return true
      allow(@class.extra_provider).to receive(:status).and_return :running
    end

    it 'tries to disable the basic service if it is enabled' do
      expect(@class.extra_provider).to receive(:disable)
      @class.disable_basic_service
    end

    it 'tries to stop the service if it is running' do
      expect(@class.extra_provider).to receive(:stop)
      @class.disable_basic_service
    end

    it 'does not try to stop a systemd running service' do
      allow(@class).to receive(:primitive_class).and_return('systemd')
      expect(@class.extra_provider).to receive(:stop).never
      @class.disable_basic_service
    end
  end

end

