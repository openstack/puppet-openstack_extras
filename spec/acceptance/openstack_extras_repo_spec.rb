require 'spec_helper_acceptance'

describe 'openstack_extras::repo::*' do

  context 'default parameters' do

    release = 'mitaka'
    it 'should work with no errors' do
      pp= <<-EOS
        include openstack_integration
        include openstack_integration::repos
      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it 'should be able to install openstack packages' do
      if os[:family] == 'Debian'
        expect(command('apt-get install -y python-openstackclient').exit_code).to be_zero
        expect(command('apt-cache policy python-openstackclient | grep -A 1 \*\*\*').stdout).to match(/#{release}/)
      elsif os[:family] == 'RedHat'
        expect(command('dnf install -y python-openstackclient').exit_code).to be_zero
        expect(command('dnf list python-openstackclient | grep -A 1 "Installed Packages"').stdout).to match(/@rdo-release/)
      end
    end
  end
end
