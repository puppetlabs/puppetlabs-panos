# frozen_string_literal: true

require 'spec_helper'

module Puppet::Provider::PanosPathMonitor; end
require 'puppet/provider/panos_path_monitor/panos_path_monitor'

RSpec.describe Puppet::Provider::PanosPathMonitor::PanosPathMonitor do
  subject(:provider) { described_class.new }

  describe '#initialize' do
    it {
      expect(provider.instance_variable_get('@version_label')).to eq('ip')
    }
  end
end
