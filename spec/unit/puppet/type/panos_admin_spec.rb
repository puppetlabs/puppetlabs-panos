require 'spec_helper'
require 'puppet/type/panos_admin'

RSpec.describe 'the panos_admin type' do
  it 'loads' do
    expect(Puppet::Type.type(:panos_admin)).not_to be_nil
  end

  it 'has a base_xpath' do
    expect(Puppet::Type.type(:panos_admin).context.type.definition).to have_key :base_xpath
  end
end
