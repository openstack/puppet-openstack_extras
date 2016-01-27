require 'spec_helper'

describe 'openstack_extras::repo::redhat::redhat' do
  let :class_params do
    {
      :manage_rdo       => true,
      :manage_epel      => true,
      :repo_hash        => {},
      :gpgkey_hash      => {},
      :purge_unmanaged  => false,
      :package_require  => false
    }
  end

  let :paramclass_defaults do
    {
      :release        => 'mitaka',
      :repo_defaults  => { 'enabled' => '1',
                           'gpgcheck' => '1',
                           'notify' => "Exec[yum_refresh]",
                           'mirrorlist' => 'absent',
                           'require' => "Anchor[openstack_extras_redhat]"
                         },
      :gpgkey_defaults => { 'owner' => 'root',
                            'group' => 'root',
                            'mode' => '0644',
                            'before' => "Anchor[openstack_extras_redhat]"
                          }
    }
  end

  let :default_params do
    class_params.merge!(paramclass_defaults)
  end

  context 'on RedHat platforms' do
    let :facts do
      @default_facts.merge({
        :osfamily        => 'RedHat',
        :operatingsystem => 'RedHat',
        :operatingsystemrelease => '7.1',
        :operatingsystemmajrelease => '7',
        :puppetversion => Puppet.version,
      })
    end

    describe 'with default parameters' do
      let :params do
        {}.merge!(default_params)
      end

      it { is_expected.to contain_yumrepo('rdo-release').with(
        :baseurl    => "http://mirror.centos.org/centos/7/cloud/$basearch/openstack-mitaka/",
        :descr      => "OpenStack Mitaka Repository",
        :priority   => 98,
        :gpgkey     => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Cloud",
        :enabled    => '1',
        :gpgcheck   => '1',
        :mirrorlist => 'absent',
        :require    => "Anchor[openstack_extras_redhat]",
        :notify     => "Exec[yum_refresh]"
      )}

      it { is_expected.to contain_package('yum-plugin-priorities').with(
        :ensure => 'present',
      )}

      # 'metalink' property is supported from Puppet 3.5
      if Puppet.version.to_f >= 3.5
        it { is_expected.to contain_yumrepo('epel').with(
          :metalink       => "https://mirrors.fedoraproject.org/metalink?repo=epel-7&arch=\$basearch",
          :descr          => 'Extra Packages for Enterprise Linux 7 - $basearch',
          :gpgkey         => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7",
          :failovermethod => 'priority',
          :enabled        => '1',
          :gpgcheck       => '1',
          :mirrorlist     => 'absent',
          :require        => "Anchor[openstack_extras_redhat]",
          :notify         => "Exec[yum_refresh]"
        )}
      else
        it { is_expected.to contain_yumrepo('epel').with(
          :baseurl        => "https://download.fedoraproject.org/pub/epel/7/\$basearch",
          :descr          => 'Extra Packages for Enterprise Linux 7 - $basearch',
          :gpgkey         => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7",
          :failovermethod => 'priority',
          :enabled        => '1',
          :gpgcheck       => '1',
          :mirrorlist     => 'absent',
          :require        => "Anchor[openstack_extras_redhat]",
          :notify         => "Exec[yum_refresh]"
        )}
      end

      it { is_expected.to contain_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Cloud').with(
        :source     => "puppet:///modules/openstack_extras/RPM-GPG-KEY-CentOS-SIG-Cloud",
        :owner      => 'root',
        :group      => 'root',
        :mode       => '0644',
        :before     => "Anchor[openstack_extras_redhat]"
      )}

    end

    describe 'with overridden release' do
      let :params do
        default_params.merge!({ :release => 'juno' })
      end

      it { is_expected.to contain_yumrepo('rdo-release').with(
        :baseurl    => "http://mirror.centos.org/centos/7/cloud/\$basearch/openstack-juno/",
        :descr      => "OpenStack Juno Repository",
        :gpgkey     => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Cloud"
      )}

      it { is_expected.to contain_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Cloud').with(
        :source     => "puppet:///modules/openstack_extras/RPM-GPG-KEY-CentOS-SIG-Cloud"
      )}
    end

    describe 'with overridden repo hash' do
      let :params do
        default_params.merge!({ :repo_hash => {
                                   'CentOS-Base' => {
                                       'baseurl' => 'http://mymirror/$releasever/os/$basearch/',
                                       'descr'   => 'CentOS-$releasever - Base',
                                       'gpgkey'  => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6'
                                   },
                                   'CentOS-Updates' => {
                                       'baseurl' => 'http://mymirror/$releasever/updates/$basearch/',
                                       'descr'   => 'CentOS-$releasever - Updates',
                                       'gpgkey'  => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6',
                                   }
                                }
                              })
      end

      it { is_expected.to contain_yumrepo('CentOS-Base').with(
        :baseurl    => "http://mymirror/$releasever/os/$basearch/",
        :descr      => "CentOS-$releasever - Base",
        :enabled    => '1',
        :gpgcheck   => '1',
        :gpgkey     => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6',
        :mirrorlist => 'absent',
        :require    => "Anchor[openstack_extras_redhat]",
        :notify     => "Exec[yum_refresh]"
      )}

      it { is_expected.to contain_yumrepo('CentOS-Updates').with(
        :baseurl    => "http://mymirror/$releasever/updates/$basearch/",
        :descr      => "CentOS-$releasever - Updates",
        :enabled    => '1',
        :gpgcheck   => '1',
        :gpgkey     => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6',
        :mirrorlist => 'absent',
        :require    => "Anchor[openstack_extras_redhat]",
        :notify     => "Exec[yum_refresh]"
      )}

    end

    describe 'with overridden repo default' do
      let :params do
        default_params.merge!({ :repo_defaults => {
                                   'proxy' => 'http://my.proxy.com:8000'
                                }
                              })
      end

      it { is_expected.to contain_yumrepo('rdo-release').with(
        :baseurl    => "http://mirror.centos.org/centos/7/cloud/\$basearch/openstack-mitaka/",
        :descr      => "OpenStack Mitaka Repository",
        :gpgkey     => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Cloud",
        :proxy     => "http://my.proxy.com:8000"
      )}
    end

    describe 'with overridden gpgkey default' do
      let :params do
        default_params.merge!({ :gpgkey_defaults => {
                                   'owner' => 'steve'
                                }
                              })
      end

      it { is_expected.to contain_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Cloud').with(
        :owner => "steve"
      )}
    end

    describe 'with epel management disabled' do
      let :params do
        default_params.merge!({ :manage_epel => false })
      end

      it { is_expected.to_not contain_yumrepo('epel') }
    end

    describe 'with rdo management disabled' do
      let :params do
        default_params.merge!({ :manage_rdo => false })
      end

      it { is_expected.to_not contain_yumrepo('rdo-release') }
    end
    describe 'with manage_priorities disabled' do
      let :params do
        default_params.merge!({ :manage_priorities => false })
      end

      it { is_expected.to_not contain_package('yum-plugin-priorities') }
    end
  end
end
