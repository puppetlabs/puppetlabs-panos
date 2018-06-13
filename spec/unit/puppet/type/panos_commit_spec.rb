require 'spec_helper'
require 'puppet/type/panos_commit'

RSpec.describe 'the panos_commit type' do
  it 'loads' do
    expect(Puppet::Type.type(:panos_commit)).not_to be_nil
  end
end
