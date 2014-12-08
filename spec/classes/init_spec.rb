require 'spec_helper'

describe 'zfsautosnap', :type => 'class' do

  context "on an unknown OS" do
    let :facts do
      {
        :osfamily => 'Darwin'
      }
    end

    it {
      expect { should raise_error(Puppet::Error, /Unsupported OSFamily/) }
    }
  end

  context "on Solaris 5.10" do
    let :facts do
      {
        :osfamily               => 'Solaris',
        :operatingsystem        => 'Solaris',
        :operatingsystemrelease => '5.10',
      }
    end

    it { should_not contain_package('ksh').with_provider('pkgutil') }
    it { should contain_package('mbuffer').with_provider('pkgutil') }

    it { should contain_file('/usr/bin/ksh93').with( {
      :target => '/opt/csw/bin/ksh'
    } ) }

  end

  context "on Solaris 5.11" do
    let :facts do
      {
        :osfamily               => 'Solaris',
        :operatingsystem        => 'Solaris',
        :operatingsystemrelease => '5.11',
      }
    end

    it { should_not contain_package('ksh').with_provider('pkgutil') }
    it { should contain_package('mbuffer').with_provider('pkgutil') }

    it { should_not contain_file('/usr/bin/ksh93') }
  end

end
