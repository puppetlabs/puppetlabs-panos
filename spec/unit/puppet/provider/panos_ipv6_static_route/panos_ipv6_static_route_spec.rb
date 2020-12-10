# frozen_string_literal: true

require 'spec_helper'

module Puppet::Provider::PanosIpv6StaticRoute; end
require 'puppet/provider/panos_ipv6_static_route/panos_ipv6_static_route'

RSpec.describe Puppet::Provider::PanosIpv6StaticRoute::PanosIpv6StaticRoute do
  subject(:provider) { described_class.new }

  describe '#initialize' do
    it {
      expect(provider.instance_variable_get('@version_label')).to eq('ipv6')
    }
  end
end
