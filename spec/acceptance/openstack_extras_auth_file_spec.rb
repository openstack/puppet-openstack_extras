require 'spec_helper_acceptance'

describe 'openstack_extras::auth_file' do

  context 'default parameters' do

    it 'should work with no errors' do
      pp= <<-EOS
        class { '::openstack_extras::auth_file':
          password => 'secret',
        }
      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe file('/root/openrc') do
      it  { is_expected.to be_file }
    end
  end
end
