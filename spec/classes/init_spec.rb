require 'spec_helper'

describe 'zfsautosnap', :type => 'class' do

  context "on an unknown OS" do
    let :facts do
      {
        :osfamily => 'Darwin'
      }
    end

    it {
      expect { should raise_error(Puppet::Error) }
    }
  end

  context "on Solaris" do
    let :facts do
      {
        :osfamily => 'Solaris',
        :operatingsystem => 'Solaris',
      }
    end

    it do
      should contain_package('ksh').with_provider('pkgutil')

      should contain_file('/usr/bin/ksh93').with( {
        :target => '/opt/csw/bin/ksh'
      } )
    end

  end

end
