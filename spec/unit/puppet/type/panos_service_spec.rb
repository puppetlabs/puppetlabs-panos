# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/panos_service'
require 'support/shared_examples'

RSpec.describe 'the panos_service type' do
  it 'loads' do
    expect(Puppet::Type.type(:panos_service)).not_to be_nil
  end

  it 'has a base_xpath' do
    expect(Puppet::Type.type(:panos_service).context.type.definition).to have_key :base_xpath
  end

  include_examples '`name` exceeds 63 characters', :panos_service

  include_examples '`name` does not exceed 63 characters', :panos_service
end
