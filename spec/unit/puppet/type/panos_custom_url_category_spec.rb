require 'spec_helper'
require 'support/shared_examples'
require 'puppet/type/panos_custom_url_category'

RSpec.describe 'the panos_custom_url_category type' do
  it 'loads' do
    expect(Puppet::Type.type(:panos_custom_url_category)).not_to be_nil
  end

  it 'has a base_xpath' do
    expect(Puppet::Type.type(:panos_custom_url_category).context.type.definition).to have_key :base_xpath
  end

  include_examples '`name` exceeds 63 characters', :panos_custom_url_category

  include_examples '`name` does not exceed 63 characters', :panos_custom_url_category
end
