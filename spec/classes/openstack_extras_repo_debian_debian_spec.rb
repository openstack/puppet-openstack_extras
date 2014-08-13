require 'spec_helper'

describe 'openstack_extras::repo::debian::debian' do
  let :class_params do
    {
      :manage_whz       => true,
      :source_hash      => {},
      :source_defaults  => {},
      :package_require  => false
    }
  end

  let :paramclass_defaults do
    {
      :release        => 'icehouse'
    }
  end

  let :default_params do
    class_params.merge!(paramclass_defaults)
  end

  context 'on Debian platforms' do
    let :facts do
      {
        :osfamily        => 'Debian',
        :operatingsystem => 'Debian',
        :lsbdistid       => 'Debian'
      }
    end

    describe 'with default parameters' do
      let :params do
        {}.merge!(default_params)
      end

      it { should contain_apt__source('debian_wheezy').with(
        :location           => 'http://archive.gplhost.com/debian',
        :release            => 'icehouse',
        :repos              => 'main',
        :required_packages  => 'gplhost-archive-keyring'
      )}

      it { should contain_apt__source('debian_wheezy_backports').with(
        :location => 'http://archive.gplhost.com/debian',
        :release  => 'icehouse-backports',
        :repos    => 'main'
      )}

    end

    describe 'with overridden release' do
      let :params do
        default_params.merge!({ :release => 'juno' })
      end

      it { should contain_apt__source('debian_wheezy').with(
        :location           => 'http://archive.gplhost.com/debian',
        :release            => 'juno',
        :repos              => 'main',
        :required_packages  => 'gplhost-archive-keyring'
      )}

      it { should contain_apt__source('debian_wheezy_backports').with(
        :location => 'http://archive.gplhost.com/debian',
        :release  => 'juno-backports',
        :repos    => 'main'
      )}

    end

    describe 'with overridden source hash' do
      let :params do
        default_params.merge!({ :source_hash => {
                                   'debian_unstable' => {
                                       'location' => 'http://mymirror/debian/',
                                       'repos'    => 'main',
                                       'release'  => 'unstable'
                                   },
                                   'puppetlabs' => {
                                       'location'   => 'http://apt.puppetlabs.com',
                                       'repos'      => 'main',
                                       'release'    => 'wheezy',
                                       'key'        => '4BD6EC30',
                                       'key_server' => 'pgp.mit.edu'
                                   }
                                }
                              })
      end

      it { should contain_apt__source('debian_unstable').with(
        :location           => 'http://mymirror/debian/',
        :release            => 'unstable',
        :repos              => 'main'
      )}

      it { should contain_apt__source('puppetlabs').with(
        :location           => 'http://apt.puppetlabs.com',
        :repos              => 'main',
        :release            => 'wheezy',
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

      it { should contain_apt__source('debian_wheezy').with(
        :location           => 'http://archive.gplhost.com/debian',
        :release            => 'icehouse',
        :repos              => 'main',
        :required_packages  => 'gplhost-archive-keyring',
        :include_src        => 'true'
      )}

      it { should contain_apt__source('debian_wheezy_backports').with(
        :location       => 'http://archive.gplhost.com/debian',
        :release        => 'icehouse-backports',
        :repos          => 'main',
        :include_src    => 'true'
      )}

    end
  end
end
