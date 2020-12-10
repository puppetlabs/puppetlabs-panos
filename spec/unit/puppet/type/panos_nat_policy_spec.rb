# frozen_string_literal: true

require 'spec_helper'
require 'support/shared_examples'
require 'puppet/type/panos_nat_policy'

RSpec.describe 'the panos_nat_policy type' do
  it 'loads' do
    expect(Puppet::Type.type(:panos_nat_policy)).not_to be_nil
  end

  include_examples '`name` exceeds 63 characters', :panos_nat_policy

  include_examples '`name` does not exceed 63 characters', :panos_nat_policy
end
