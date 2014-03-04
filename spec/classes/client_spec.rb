require 'spec_helper'

describe 'zfsautosnap::client', :type => 'class' do
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

    end
  end
end
