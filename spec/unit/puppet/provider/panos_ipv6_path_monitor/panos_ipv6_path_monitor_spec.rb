require 'spec_helper'

module Puppet::Provider::PanosIpv6PathMonitor; end
require 'puppet/provider/panos_ipv6_path_monitor/panos_ipv6_path_monitor'

RSpec.describe Puppet::Provider::PanosIpv6PathMonitor::PanosIpv6PathMonitor do
  subject(:provider) { described_class.new }

  describe '#initialize' do
    it {
      expect(provider.instance_variable_get('@version_label')).to eq('ipv6')
    }
  end
end
