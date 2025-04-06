require 'spec_helper'

describe 'openstack_extras::repo::debian::debian' do
  shared_examples 'openstack_extras::repo::debian::debian' do
    let :class_params do
      {
        :manage_deb      => true,
        :source_hash     => {},
        :source_defaults => {},
        :package_require => false,
        :use_extrepo     => false,
      }
    end

    let :paramclass_defaults do
      {
        :release => 'epoxy'
      }
    end

    let :default_params do
      class_params.merge!(paramclass_defaults)
    end

    context 'with default params' do
      it { should contain_exec('/usr/bin/extrepo enable openstack_epoxy').with(
        :command => "/bin/true # comment to satisfy puppet syntax requirements
apt-get update
apt-get install -y extrepo
extrepo enable openstack_epoxy
apt-get update
",
      )}
    end

    context 'wallaby with extrepo' do
      let :params do
        {
          :release     => 'wallaby',
          :use_extrepo => true,
        }
      end
      it { should contain_exec('/usr/bin/extrepo enable openstack_wallaby').with(
        :command => "/bin/true # comment to satisfy puppet syntax requirements
apt-get update
apt-get install -y extrepo
extrepo enable openstack_wallaby
apt-get update
",
      )}
    end

    context 'with extrepo set to false' do
      let :params do
        {
          :use_extrepo => false,
        }
      end

      it { should contain_apt__source('debian-openstack-backports').with(
        :location => "http://#{facts[:os]['distro']['codename']}-epoxy.debian.net/debian",
        :release  => "#{facts[:os]['distro']['codename']}-epoxy-backports",
        :repos    => 'main',
      )}

      it { should contain_apt__source('debian-openstack-backports-nochange').with(
        :location => "http://#{facts[:os]['distro']['codename']}-epoxy.debian.net/debian",
        :release  => "#{facts[:os]['distro']['codename']}-epoxy-backports-nochange",
        :repos    => 'main'
      )}

      it { should contain_exec('installing openstack-backports-archive-keyring') }
    end

    context 'with overridden release' do
      let :params do
        default_params.merge!({ :release => 'pike' })
      end

      it { should contain_apt__source('debian-openstack-backports').with(
        :location => "http://#{facts[:os]['distro']['codename']}-pike.debian.net/debian",
        :release  => "#{facts[:os]['distro']['codename']}-pike-backports",
        :repos    => 'main',
      )}

      it { should contain_apt__source('debian-openstack-backports-nochange').with(
        :location => "http://#{facts[:os]['distro']['codename']}-pike.debian.net/debian",
        :release  => "#{facts[:os]['distro']['codename']}-pike-backports-nochange",
        :repos    => 'main'
      )}

      it { should contain_exec('installing openstack-backports-archive-keyring') }
    end

    context 'when not managing openstack repo' do
      let :params do
        default_params.merge!({ :manage_deb => false })
      end

      it { should_not contain_exec('installing openstack-backports-archive-keyring') }
    end

    context 'with overridden source hash' do
      let :params do
        default_params.merge!({
          :source_hash => {
            'debian_unstable' => {
              'location' => 'http://mymirror/debian/',
              'repos'    => 'main',
              'release'  => 'unstable'
            },
            'puppetlabs' => {
              'location' => 'http://apt.puppetlabs.com',
              'repos'    => 'main',
              'release'  => facts[:os]['distro']['codename'],
              'key'      => { 'id' => '4BD6EC30', 'server' => 'pgp.mit.edu' }
            }
          },
          :use_extrepo => false
        })
      end

      it { should contain_apt__source('debian_unstable').with(
        :location    => 'http://mymirror/debian/',
        :release     => 'unstable',
        :repos       => 'main',
      )}

      it { should contain_apt__source('puppetlabs').with(
        :location    => 'http://apt.puppetlabs.com',
        :repos       => 'main',
        :release     => facts[:os]['distro']['codename'],
        :key         => { 'id' => '4BD6EC30', 'server' => 'pgp.mit.edu' },
      )}

      it { should contain_exec('installing openstack-backports-archive-keyring') }
    end

    context 'with overridden source default' do
      let :params do
        default_params.merge!({
          :source_hash     => {
            'debian_unstable' => {
              'location' => 'http://mymirror/debian/',
              'repos'    => 'main',
              'release'  => 'unstable'
            },
          },
          :source_defaults => {
            'include' => { 'src' => true }
          },
          :use_extrepo     => false
        })
      end

      it { should contain_apt__source('debian_unstable').with(
        :include     => { 'src' => true },
        :location    => 'http://mymirror/debian/',
        :release     => 'unstable',
        :repos       => 'main',
      )}

      it { should contain_exec('installing openstack-backports-archive-keyring') }
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      if facts[:os]['name'] == 'Debian'
        it_behaves_like 'openstack_extras::repo::debian::debian'
      end
    end
  end
end
