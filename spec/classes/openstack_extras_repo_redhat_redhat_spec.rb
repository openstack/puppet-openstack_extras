require 'spec_helper'

describe 'openstack_extras::repo::redhat::redhat' do
  shared_examples 'openstack_extras::repo::redhat::redhat' do
    context 'with default parameters' do
      it { should contain_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Cloud').with(
        :source => 'puppet:///modules/openstack_extras/RPM-GPG-KEY-CentOS-SIG-Cloud',
        :owner  => 'root',
        :group  => 'root',
        :mode   => '0644',
        :tag    => 'openstack-extras-repo',
      )}
      it { should contain_yumrepo('rdo-release').with(
        :baseurl         => "http://mirror.stream.centos.org/SIGs/$stream/cloud/$basearch/openstack-epoxy/",
        :descr           => "OpenStack Epoxy Repository",
        :gpgkey          => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Cloud',
        :enabled         => '1',
        :gpgcheck        => '1',
        :mirrorlist      => 'absent',
        :module_hotfixes => true,
        :notify          => 'Exec[yum_refresh]',
        :tag             => 'openstack-extras-repo',
      )}

      it { should_not contain_file("/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-#{facts[:os]['release']['major']}") }
      it { should_not contain_yumrepo('epel') }

      it { should_not contain_resources('yumrepo').with_purge(true) }

      it { should contain_exec('yum_refresh').with(
        :command     => '/usr/bin/dnf clean all',
        :refreshonly => true,
      )}

      it { should_not contain_exec('yum_update') }
    end

    context 'with parameters' do
      let :params do
        {
          :manage_rdo      => false,
          :manage_epel     => true,
          :purge_unmanaged => true,
          :package_require => true,
          :update_packages => true,
        }
      end

      it { should_not contain_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Cloud') }
      it { should_not contain_yumrepo('rdo-release') }

      it { should contain_file("/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-#{facts[:os]['release']['major']}").with(
        :source => "puppet:///modules/openstack_extras/RPM-GPG-KEY-EPEL-#{facts[:os]['release']['major']}",
        :owner  => 'root',
        :group  => 'root',
        :mode   => '0644',
        :tag    => 'openstack-extras-repo',
      )}

      it { should contain_yumrepo('epel').with(
        :metalink       => "https://mirrors.fedoraproject.org/metalink?repo=epel-#{facts[:os]['release']['major']}&arch=\$basearch",
        :descr          => "Extra Packages for Enterprise Linux #{facts[:os]['release']['major']} - \$basearch",
        :gpgkey         => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-#{facts[:os]['release']['major']}",
        :failovermethod => 'priority',
        :enabled        => '1',
        :gpgcheck       => '1',
        :mirrorlist     => 'absent',
        :notify         => 'Exec[yum_refresh]',
        :tag            => 'openstack-extras-repo',
      )}

      it { should contain_resources('yumrepo').with_purge(true) }

      it { should contain_exec('yum_refresh').with(
        :command     => '/usr/bin/dnf clean all',
        :refreshonly => true,
      )}

      it { should contain_exec('yum_update').with(
        :command     => '/usr/bin/dnf update -y',
        :refreshonly => true,
        :timeout     => 600,
      )}
    end

    context 'with update_timeout' do
      let :params do
        {
          :update_packages => true,
          :update_timeout  => 1200,
        }
      end


      it { should contain_exec('yum_update').with(
        :command     => '/usr/bin/dnf update -y',
        :refreshonly => true,
        :timeout     => 1200,
      )}
    end

    context 'with overridden release' do
      let :params do
        {
          :release    => 'juno',
          :manage_rdo => true,
        }
      end

      it { should contain_yumrepo('rdo-release').with(
        :baseurl => "http://mirror.stream.centos.org/SIGs/$stream/cloud/$basearch/openstack-juno/",
        :descr   => 'OpenStack Juno Repository',
      )}
    end

    context 'with centos_mirror_url' do
      let :params do
        {
          :manage_rdo        => true,
          :centos_mirror_url => 'http://foo.bar',
        }
      end

      it { should contain_yumrepo('rdo-release').with(
        :baseurl => "http://foo.bar/SIGs/$stream/cloud/$basearch/openstack-epoxy/",
      )}
    end

    context 'with repo_defaults and gpgkey_defaults' do
      let :params do
        {
          :manage_rdo      => true,
          :manage_epel     => true,
          :repo_hash       => {
            'CentOS-Example' => {
              'baseurl' => 'http://example.com/$releasever/os/$basearch/',
              'descr'   => 'CentOS-$releasever - Example',
              'gpgkey'  => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Example',
            },
          },
          :gpgkey_hash     => {
            '/etc/pki/rpm-gpg/RPM-GPG-KEY-Example' => {
              'source' => 'puppet:///modules/openstack_extras/RPM-GPG-KEY-Example',
            }
          },
          :repo_defaults   => {
            'proxy' => 'http://example.com:8000',
          },
          :gpgkey_defaults => {
            'owner' => 'steve',
            'force' => true,
          },
        }
      end

      it { should contain_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Cloud').with(
        :owner  => 'steve',
        :group  => 'root',
        :mode   => '0644',
        :force  => true,
        :tag    => 'openstack-extras-repo',
      )}

      it { should contain_yumrepo('rdo-release').with(
        :enabled    => '1',
        :gpgcheck   => '1',
        :mirrorlist => 'absent',
        :proxy      => 'http://example.com:8000',
        :notify     => 'Exec[yum_refresh]',
        :tag        => 'openstack-extras-repo',
      )}

      it { should contain_file("/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-#{facts[:os]['release']['major']}").with(
        :owner  => 'steve',
        :group  => 'root',
        :mode   => '0644',
        :force  => true,
        :tag    => 'openstack-extras-repo',
      )}

      it { should contain_yumrepo('epel').with(
        :enabled    => '1',
        :gpgcheck   => '1',
        :mirrorlist => 'absent',
        :proxy      => 'http://example.com:8000',
        :notify     => 'Exec[yum_refresh]',
        :tag        => 'openstack-extras-repo',
      )}

      it { should contain_yumrepo('CentOS-Example').with(
        :enabled    => '1',
        :gpgcheck   => '1',
        :mirrorlist => 'absent',
        :proxy      => 'http://example.com:8000',
        :notify     => 'Exec[yum_refresh]',
        :tag        => 'openstack-extras-repo',
      )}

      it { should contain_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-Example').with(
        :owner  => 'steve',
        :group  => 'root',
        :mode   => '0644',
        :force  => true,
        :tag    => 'openstack-extras-repo',
      )}
    end

    context 'with overridden repo_hash and gpgkey_hash' do
      let :params do
        {
          :repo_hash   => {
            'CentOS-Base' => {
              'baseurl' => 'http://mymirror/$releasever/os/$basearch/',
              'descr'   => 'CentOS-$releasever - Base',
              'gpgkey'  => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS',
            },
            'CentOS-Updates' => {
              'baseurl' => 'http://mymirror/$releasever/updates/$basearch/',
              'descr'   => 'CentOS-$releasever - Updates',
              'gpgkey'  => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS',
            }
          },
          :gpgkey_hash => {
            '/etc/pki/rpm-gpg/RPM-GPG-KEY-Something' => {
              'source' => 'puppet:///modules/openstack_extras/RPM-GPG-KEY-Something',
            }
          },
        }
      end

      it { should contain_yumrepo('CentOS-Base').with(
        :baseurl    => 'http://mymirror/$releasever/os/$basearch/',
        :descr      => 'CentOS-$releasever - Base',
        :enabled    => '1',
        :gpgcheck   => '1',
        :gpgkey     => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS',
        :mirrorlist => 'absent',
        :notify     => 'Exec[yum_refresh]',
        :tag        => 'openstack-extras-repo',
      )}

      it { should contain_yumrepo('CentOS-Updates').with(
        :baseurl    => "http://mymirror/$releasever/updates/$basearch/",
        :descr      => "CentOS-$releasever - Updates",
        :enabled    => '1',
        :gpgcheck   => '1',
        :gpgkey     => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS',
        :mirrorlist => 'absent',
        :notify     => 'Exec[yum_refresh]',
        :tag        => 'openstack-extras-repo',
      )}

      it { should contain_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-Something').with(
        :source => 'puppet:///modules/openstack_extras/RPM-GPG-KEY-Something',
        :owner  => 'root',
        :group  => 'root',
        :mode   => '0644',
        :tag    => 'openstack-extras-repo',
      )}
    end

    context 'with repo_source_hash' do
      let :params do
        {
          :repo_source_hash => {
            'delorean.repo'      => 'https://trunk.rdoproject.org/centos/puppet-passed-ci/delorean.repo',
            'delorean-deps.repo' => 'https://trunk.rdoproject.org/centos/delorean-deps.repo',
          },
        }
      end

      it { should contain_file('delorean.repo').with(
        :ensure  => 'file',
        :path    => '/etc/yum.repos.d/delorean.repo',
        :source  => 'https://trunk.rdoproject.org/centos/puppet-passed-ci/delorean.repo',
        :replace => true,
        :notify  => 'Exec[yum_refresh]',
      )}

      it { should contain_file('delorean-deps.repo').with(
        :ensure  => 'file',
        :path    => '/etc/yum.repos.d/delorean-deps.repo',
        :source  => 'https://trunk.rdoproject.org/centos/delorean-deps.repo',
        :replace => true,
        :notify  => 'Exec[yum_refresh]',
      )}
    end

    context 'with repo_source_hash and repo_replace is false' do
      let :params do
        {
          :repo_source_hash => {
            'thing.repo' => 'https://trunk.rdoproject.org/some/thing.repo',
          },
          :repo_replace     => false,
        }
      end

      it { should contain_file('thing.repo').with(
        :ensure  => 'file',
        :path    => '/etc/yum.repos.d/thing.repo',
        :source  => 'https://trunk.rdoproject.org/some/thing.repo',
        :replace => false,
        :notify  => 'Exec[yum_refresh]',
      )}
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      if facts[:os]['family'] == 'RedHat'
        it_behaves_like 'openstack_extras::repo::redhat::redhat'
      end
    end
  end
end
