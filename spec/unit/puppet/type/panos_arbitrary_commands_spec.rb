# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/panos_arbitrary_commands'

RSpec.describe 'the panos_arbitrary_commands type' do
  it 'loads' do
    expect(Puppet::Type.type(:panos_arbitrary_commands)).not_to be_nil
  end
end
