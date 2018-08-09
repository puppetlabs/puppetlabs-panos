require 'spec_helper'
require 'puppet/type/panos_tag'

RSpec.describe 'the panos_tag type' do
  it 'loads' do
    expect(Puppet::Type.type(:panos_tag)).not_to be_nil
  end

  it 'has a base_xpath' do
    expect(Puppet::Type.type(:panos_tag).context.type.definition).to have_key :base_xpath
  end
end
