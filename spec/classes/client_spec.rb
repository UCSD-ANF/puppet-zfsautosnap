require 'spec_helper'

describe 'zfsautosnap::client', :type => 'class' do
  basefmri = 'svc:/system/filesystem/zfs/auto-snapshot'
  let(:pre_conditions) {
    "file {'/usr/local/sbin': ensure => 'directory'}"
  }
  context 'on Solaris' do
    let(:facts) {{
      :osfamily => 'Solaris',
      :operatingsystem => 'Solaris',
    }}

    context 'with no parameters' do
      it { expect { should raise_error(Puppet::Error) } }
    end

    context 'with required parameters' do
      let(:params) {{
        :target_hostname => 'receiver.example.priv',
        :client_ssh_privkey_source => 'puppet:///site/id_dsa',
      }}

      it { should contain_file('zfsbackups client ssh privkey') }
      it { should contain_package('IGPPzfsautosnap') }
      it { should contain_file('/usr/local/sbin/checkzfssnaplock') }
      it { should contain_file('/usr/local/sbin/clearzfssnaplock') }
      it { should contain_service("#{basefmri}:hourly").with_enable(true) }
      it { should contain_service("#{basefmri}:daily").with_enable(true) }
      it { should contain_service("#{basefmri}:monthly").with_enable(false) }
      it { should contain_service("#{basefmri}:weekly").with_enable(false) }
      it { should contain_service("#{basefmri}:frequent").with_enable(false) }
      it { should contain_service("#{basefmri}:event").with_enable(false) }
      it { should contain_svcprop("zfssnap hourly verbose").with({
        :fmri     => "#{basefmri}:hourly",
        :property => 'zfs/verbose',
        :value    => 'false',
      }) }
      it { should contain_svcprop("zfssnap daily verbose").with({
        :fmri     => "#{basefmri}:daily",
        :property => 'zfs/verbose',
        :value    => 'false',
      }) }
    end

    context 'with verbose params = true' do
      let(:params) {{
        :target_hostname           => 'receiver.example.priv',
        :client_ssh_privkey_source => 'puppet:///site/id_dsa',
        :verbose_hourly            => true,
        :verbose_daily             => true,
      }}
      it { should contain_svcprop("zfssnap hourly verbose").with({
        :fmri     => "#{basefmri}:hourly",
        :property => 'zfs/verbose',
        :value    => 'true',
      }) }
      it { should contain_svcprop("zfssnap daily verbose").with({
        :fmri     => "#{basefmri}:daily",
        :property => 'zfs/verbose',
        :value    => 'true',
      }) }
    end

    context 'with verbose params = "invalid"' do
      let(:params) {{
        :target_hostname           => 'receiver.example.priv',
        :client_ssh_privkey_source => 'puppet:///site/id_dsa',
        :verbose_hourly            => 'invalid',
        :verbose_daily             => 'invalid',
      }}

      it 'should complain about non-boolean params' do
        expect { should raise_error(Puppet::Error) }
      end
    end

    context 'with enable params = "invalid"' do
      let(:params) {{
        :target_hostname           => 'receiver.example.priv',
        :client_ssh_privkey_source => 'puppet:///site/id_dsa',
        :enable_hourly            => 'invalid',
        :enable_daily             => 'invalid',
      }}

      it 'should complain about non-boolean params' do
        expect { should raise_error(Puppet::Error) }
      end
    end

    context 'with enable params = false' do
      let(:params) {{
        :target_hostname           => 'receiver.example.priv',
        :client_ssh_privkey_source => 'puppet:///site/id_dsa',
        :enable_hourly             => false,
        :enable_daily              => false,
      }}
      it { should contain_service("#{basefmri}:hourly").with_enable(false) }
      it { should contain_service("#{basefmri}:daily").with_enable(false) }
      it { should contain_service("#{basefmri}:monthly").with_enable(false) }
      it { should contain_service("#{basefmri}:weekly").with_enable(false) }
      it { should contain_service("#{basefmri}:frequent").with_enable(false) }
      it { should contain_service("#{basefmri}:event").with_enable(false) }
    end
  end
end
