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
        :operatingsystem => 'Debian',
        :lsbdistid       => 'Debian'
      }
    end

    describe 'with default parameters' do
      let :params do
        {}.merge!(default_params)
      end

      it { is_expected.to contain_apt__source('debian_wheezy').with(
        :location           => 'http://archive.gplhost.com/debian',
        :release            => 'kilo',
        :repos              => 'main',
      )}

      it { is_expected.to contain_apt__source('debian_wheezy_backports').with(
        :location => 'http://archive.gplhost.com/debian',
        :release  => 'kilo-backports',
        :repos    => 'main'
      )}

      it { is_expected.to contain_exec('installing gplhost-archive-keyring') }
    end

    describe 'with overridden release' do
      let :params do
        default_params.merge!({ :release => 'juno' })
      end

      it { is_expected.to contain_apt__source('debian_wheezy').with(
        :location           => 'http://archive.gplhost.com/debian',
        :release            => 'juno',
        :repos              => 'main',
      )}

      it { is_expected.to contain_apt__source('debian_wheezy_backports').with(
        :location => 'http://archive.gplhost.com/debian',
        :release  => 'juno-backports',
        :repos    => 'main'
      )}

      it { is_expected.to contain_exec('installing gplhost-archive-keyring') }
    end

    describe 'when not managing wheezy repo' do
      let :params do
        default_params.merge!({ :manage_whz => false })
      end

      it { is_expected.to_not contain_exec('installing gplhost-archive-keyring') }
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

      it { is_expected.to contain_apt__source('debian_unstable').with(
        :location           => 'http://mymirror/debian/',
        :release            => 'unstable',
        :repos              => 'main'
      )}

      it { is_expected.to contain_apt__source('puppetlabs').with(
        :location           => 'http://apt.puppetlabs.com',
        :repos              => 'main',
        :release            => 'wheezy',
        :key                => '4BD6EC30',
        :key_server         => 'pgp.mit.edu'
      )}

      it { is_expected.to contain_exec('installing gplhost-archive-keyring') }
    end

    describe 'with overridden source default' do
      let :params do
        default_params.merge!({ :source_hash => {
                                   'debian_unstable' => {
                                       'location' => 'http://mymirror/debian/',
                                       'repos'    => 'main',
                                       'release'  => 'unstable'
                                   },
                                }
                              })
        default_params.merge!({ :source_defaults => {
                                   'include_src' => 'true'
                                }
                              })
      end

      it { is_expected.to contain_apt__source('debian_unstable').with(
        :location           => 'http://mymirror/debian/',
        :release            => 'unstable',
        :repos              => 'main',
        :include_src        => 'true'
      )}

      it { is_expected.to contain_exec('installing gplhost-archive-keyring') }
    end
  end
end
