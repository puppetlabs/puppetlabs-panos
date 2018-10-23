require 'spec_helper'

describe 'panos::server' do
  test_on = {
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
    ],
  }

  on_supported_os(test_on).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_cond) { 'service { "puppetserver": }' }

      it { is_expected.to compile }
      it { is_expected.to contain_class('resource_api::server') }
    end
  end
end
