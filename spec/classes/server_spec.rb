require 'spec_helper'

describe 'zfsautosnap::server', :type => 'class' do
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
        :client_ssh_pubkey => 'ABCABC123123GARBAGE',
        :client_ssh_pubkey_type => 'ssh-dss',
      }}

      it {
        should contain_ssh_authorized_key('zfsautosnap client key')
        should contain_zpool('zfsbackups')
      }

      context 'with target_pool = foo' do
        before do
          params.merge!({
            :target_pool => 'foo',
          })
        end

        it { should contain_zpool('foo') }
      end
    end

  end
end
