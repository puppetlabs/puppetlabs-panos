require 'spec_helper'
require 'puppet/type/panos_zone'

RSpec.describe 'the panos_zone type' do
  it 'loads' do
    expect(Puppet::Type.type(:panos_zone)).not_to be_nil
  end

  it 'has a base_xpath' do
    expect(Puppet::Type.type(:panos_zone).context.type.definition).to have_key :base_xpath
  end
end
