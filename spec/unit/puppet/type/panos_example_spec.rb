require 'spec_helper'
require 'puppet/type/panos_example'

RSpec.describe 'the panos_example type' do
  it 'loads' do
    expect(Puppet::Type.type(:panos_example)).not_to be_nil
  end
end
