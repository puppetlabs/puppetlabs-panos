require 'spec_helper'
require 'puppet/type/panos_address'

RSpec.describe 'the panos_address type' do
  it 'loads' do
    expect(Puppet::Type.type(:panos_address)).not_to be_nil
  end

  it 'has a base_xpath' do
    expect(Puppet::Type.type(:panos_address).context.type.definition).to have_key :base_xpath
  end
end
