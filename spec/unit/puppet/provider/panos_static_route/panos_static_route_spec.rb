require 'spec_helper'
require 'support/matchers/have_xml'
require 'support/shared_examples'

module Puppet::Provider::PanosStaticRoute; end
require 'puppet/provider/panos_static_route/panos_static_route'

RSpec.describe Puppet::Provider::PanosStaticRoute::PanosStaticRoute do
  subject(:provider) { described_class.new }

  describe '#initialize' do
    it {
      expect(provider.instance_variable_get('@version_label')).to eq('ip')
    }
  end
end
