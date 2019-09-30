require 'spec_helper'
require 'support/shared_examples'
require 'puppet/type/panos_profiles_url_filtering'

RSpec.describe 'the panos_profiles_url_filtering type' do
  it 'loads' do
    expect(Puppet::Type.type(:panos_profiles_url_filtering)).not_to be_nil
  end

  it 'has a base_xpath' do
    expect(Puppet::Type.type(:panos_profiles_url_filtering).context.type.definition).to have_key :base_xpath
  end

  include_examples '`name` exceeds 63 characters', :panos_profiles_url_filtering

  include_examples '`name` does not exceed 63 characters', :panos_profiles_url_filtering
end
