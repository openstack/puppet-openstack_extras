require 'spec_helper'

describe 'openstack_extras::repo::debian::debian' do
  let :class_params do
    {
      :manage_deb       => true,
      :source_hash      => {},
      :source_defaults  => {},
      :package_require  => false
    }
  end

  let :paramclass_defaults do
    {
      :release        => 'queens'
    }
  end

  let :default_params do
    class_params.merge!(paramclass_defaults)
  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily        => 'Debian',
        :operatingsystem => 'Debian',
        :lsbdistid       => 'Debian',
        :lsbdistcodename => 'stretch',
        :lsbdistrelease  => '9'
      })
    end

    describe 'with default parameters' do
      let :params do
        {}.merge!(default_params)
      end

      it { is_expected.to contain_apt__source('debian-openstack-backports').with(
        :location           => 'http://stretch-queens.debian.net/debian',
        :release            => 'stretch-queens-backports',
        :repos              => 'main',
      )}

      it { is_expected.to contain_apt__source('debian-openstack-backports-nochange').with(
        :location => 'http://stretch-queens.debian.net/debian',
        :release  => 'stretch-queens-backports-nochange',
        :repos    => 'main'
      )}

      it { is_expected.to contain_exec('installing openstack-backports-archive-keyring') }
    end

    describe 'with overridden release' do
      let :params do
        default_params.merge!({ :release => 'pike' })
      end

      it { is_expected.to contain_apt__source('debian-openstack-backports').with(
        :location           => 'http://stretch-pike.debian.net/debian',
        :release            => 'stretch-pike-backports',
        :repos              => 'main',
      )}

      it { is_expected.to contain_apt__source('debian-openstack-backports-nochange').with(
        :location => 'http://stretch-pike.debian.net/debian',
        :release  => 'stretch-pike-backports-nochange',
        :repos    => 'main'
      )}

      it { is_expected.to contain_exec('installing openstack-backports-archive-keyring') }
    end

    describe 'when not managing stretch repo' do
      let :params do
        default_params.merge!({ :manage_deb => false })
      end

      it { is_expected.to_not contain_exec('installing openstack-backports-archive-keyring') }
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
                                       'release'    => 'stretch',
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
        :release            => 'stretch',
        :key                => '4BD6EC30',
        :key_server         => 'pgp.mit.edu'
      )}

      it { is_expected.to contain_exec('installing openstack-backports-archive-keyring') }
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

      it { is_expected.to contain_exec('installing openstack-backports-archive-keyring') }
    end
  end
end
