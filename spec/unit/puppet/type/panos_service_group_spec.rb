# frozen_string_literal: true

require 'spec_helper'
require 'support/shared_examples'
require 'puppet/type/panos_service_group'

RSpec.describe 'the panos_service_group type' do
  it 'loads' do
    expect(Puppet::Type.type(:panos_service_group)).not_to be_nil
  end

  it 'has a base_xpath' do
    expect(Puppet::Type.type(:panos_service_group).context.type.definition).to have_key :base_xpath
  end

  include_examples '`name` exceeds 63 characters', :panos_service_group

  include_examples '`name` does not exceed 63 characters', :panos_service_group
end
