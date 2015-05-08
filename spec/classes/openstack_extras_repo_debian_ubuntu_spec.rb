require 'spec_helper'

describe 'openstack_extras::repo::debian::ubuntu' do
  let :class_params do
    {
      :manage_uca       => true,
      :source_hash      => {},
      :source_defaults  => {},
      :package_require  => false
    }
  end

  let :paramclass_defaults do
    {
      :release        => 'kilo'
    }
  end

  let :default_params do
    class_params.merge!(paramclass_defaults)
  end

  context 'on Debian platforms' do
    let :facts do
      {
        :osfamily        => 'Debian',
        :operatingsystem => 'Ubuntu',
        :lsbdistid       => 'Ubuntu',
        :lsbdistcodename => 'trusty'
      }
    end

    describe 'with default parameters' do
      let :params do
        {}.merge!(default_params)
      end

      it { should contain_apt__source('ubuntu-cloud-archive').with(
        :location           => 'http://ubuntu-cloud.archive.canonical.com/ubuntu',
        :release            => 'trusty-updates/kilo',
        :repos              => 'main',
        :required_packages  => 'ubuntu-cloud-keyring'
      )}

    end

    describe 'with overridden release' do
      let :params do
        default_params.merge!({ :release => 'juno' })
      end

      it { should contain_apt__source('ubuntu-cloud-archive').with(
        :location           => 'http://ubuntu-cloud.archive.canonical.com/ubuntu',
        :release            => 'trusty-updates/juno',
        :repos              => 'main',
        :required_packages  => 'ubuntu-cloud-keyring'
      )}

    end

    describe 'with overridden source hash' do
      let :params do
        default_params.merge!({ :source_hash => {
                                   'local_mirror' => {
                                       'location' => 'http://mymirror/ubuntu/',
                                       'repos'    => 'main',
                                       'release'  => 'trusty'
                                   },
                                   'puppetlabs' => {
                                       'location'   => 'http://apt.puppetlabs.com',
                                       'repos'      => 'main',
                                       'release'    => 'trusty',
                                       'key'        => '4BD6EC30',
                                       'key_server' => 'pgp.mit.edu'
                                   }
                                }
                              })
      end

      it { should contain_apt__source('local_mirror').with(
        :location           => 'http://mymirror/ubuntu/',
        :release            => 'trusty',
        :repos              => 'main'
      )}

      it { should contain_apt__source('puppetlabs').with(
        :location           => 'http://apt.puppetlabs.com',
        :release            => 'trusty',
        :repos              => 'main',
        :key                => '4BD6EC30',
        :key_server         => 'pgp.mit.edu'
      )}

    end

    describe 'with overridden source default' do
      let :params do
        default_params.merge!({ :source_defaults => {
                                   'include_src' => 'true'
                                }
                              })
      end

      it { should contain_apt__source('ubuntu-cloud-archive').with(
        :include_src        => 'true',
        :location           => 'http://ubuntu-cloud.archive.canonical.com/ubuntu',
        :release            => 'trusty-updates/kilo',
        :repos              => 'main',
        :required_packages  => 'ubuntu-cloud-keyring'
      )}

    end
  end
end
