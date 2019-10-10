require 'spec_helper'

describe 'openstack_extras::repo::debian::ubuntu' do
  shared_examples 'openstack_extras::repo::debian::ubuntu' do
    let :class_params do
      {
        :manage_uca      => true,
        :source_hash     => {},
        :source_defaults => {},
        :package_require => false
      }
    end

    let :paramclass_defaults do
      {
        :release => 'ussuri'
      }
    end

    let :default_params do
      class_params.merge!(paramclass_defaults)
    end

    context 'with default parameters' do
      let :params do
        {}
      end

      it { should contain_apt__source('ubuntu-cloud-archive').with(
        :location => 'http://ubuntu-cloud.archive.canonical.com/ubuntu',
        :release  => 'trusty-updates/ussuri',
        :repos    => 'main',
      )}

      it { should contain_exec('installing ubuntu-cloud-keyring') }
    end

    context 'with overridden release' do
      let :params do
        default_params.merge!({ :release => 'juno' })
      end

      it { should contain_apt__source('ubuntu-cloud-archive').with(
        :location => 'http://ubuntu-cloud.archive.canonical.com/ubuntu',
        :release  => 'trusty-updates/juno',
        :repos    => 'main',
      )}

      it { should contain_exec('installing ubuntu-cloud-keyring') }
    end

    context 'when not managing UCA' do
      let :params do
        default_params.merge!({ :manage_uca => false })
      end

      it { should_not contain_exec('installing ubuntu-cloud-keyring') }
    end

    context 'with overridden source hash' do
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
        :location => 'http://mymirror/ubuntu/',
        :release  => 'trusty',
        :repos    => 'main'
      )}

      it { should contain_apt__source('puppetlabs').with(
        :location   => 'http://apt.puppetlabs.com',
        :release    => 'trusty',
        :repos      => 'main',
        :key        => '4BD6EC30',
        :key_server => 'pgp.mit.edu'
      )}

      it { should contain_exec('installing ubuntu-cloud-keyring') }
    end

    context 'with overridden source default' do
      let :params do
        default_params.merge!({ :source_hash => {
                                   'local_mirror' => {
                                       'location' => 'http://mymirror/ubuntu/',
                                       'repos'    => 'main',
                                       'release'  => 'trusty'
                                   }
                                 }
                             })
        default_params.merge!({ :source_defaults => {
                                   'include_src' => 'true'
                                }
                              })
      end

      it { should contain_apt__source('local_mirror').with(
        :include_src => 'true',
        :location    => 'http://mymirror/ubuntu/',
        :release     => 'trusty',
        :repos       => 'main',
      )}

      it { should contain_exec('installing ubuntu-cloud-keyring') }
    end

    context 'with overridden uca repo name' do
      let :params do
        default_params.merge!({ :repo => 'proposed',
                                :uca_location => 'http://mirror.dfw.rax.openstack.org/ubuntu-cloud-archive' })
      end

      it { should contain_apt__source('ubuntu-cloud-archive').with(
        :location => 'http://mirror.dfw.rax.openstack.org/ubuntu-cloud-archive',
        :release  => 'trusty-proposed/ussuri',
        :repos    => 'main',
      )}
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts({ :lsbdistid       => 'Ubuntu',
                                            :lsbdistcodename => 'trusty',
                                            :lsbdistrelease  => '14.04' }))
      end

      if facts[:operatingsystem] == 'Ubuntu'
        it_behaves_like 'openstack_extras::repo::debian::ubuntu'
      end
    end
  end
end
