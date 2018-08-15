require 'spec_helper'
require 'puppet/type/panos_nat_policy'

RSpec.describe 'the panos_nat_policy type' do
  it 'loads' do
    expect(Puppet::Type.type(:panos_nat_policy)).not_to be_nil
  end
end
