require 'spec_helper_acceptance'

describe 'openstack_extras::repo::*' do

  context 'default parameters' do

    release = 'kilo'
    it 'should work with no errors' do
      if fact('operatingsystem') == 'CentOS'
        operatingsystem = 'redhat'
      else
        operatingsystem = fact('operatingsystem').downcase
      end
      pp= <<-EOS
        class { '::openstack_extras::repo::#{fact('osfamily').downcase}::#{operatingsystem}':
          release => #{release}
        }
      EOS


      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it 'should be able to install openstack packages' do
      case fact('osfamily')
      when 'Debian'
        expect(shell('apt-get install -y python-openstackclient').exit_code).to be_zero
        expect(shell('apt-cache policy python-openstackclient | grep -A 1 \*\*\*').stdout).to match(/#{release}/)
      when 'Redhat'
        expect(shell('yum install -y python-openstackclient').exit_code).to be_zero
        expect(shell('yum list python-openstackclient | grep -A 1 "Installed Packages"').stdout).to match(/@rdo-release/)
      end
    end
  end
end
