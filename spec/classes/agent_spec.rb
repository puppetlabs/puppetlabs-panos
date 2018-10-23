require 'spec_helper'

describe 'panos::agent' do
  test_on = {
    hardwaremodels: ['x86_64', 'i686'],
    supported_os: [
      {
        'operatingsystem'        => 'RedHat',
        'operatingsystemrelease' => ['7'],
      },
      {
        'operatingsystem'        => 'Ubuntu',
        'operatingsystemrelease' => ['16.04'],
      },
      {
        'operatingsystem'        => 'OracleLinux',
        'operatingsystemrelease' => ['7'],
      },
      {
        'operatingsystem'        => 'windows',
      },
    ],
  }

  on_supported_os(test_on).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_class('resource_api::agent') }
      it { is_expected.to contain_package('builder') }
    end
  end
end
