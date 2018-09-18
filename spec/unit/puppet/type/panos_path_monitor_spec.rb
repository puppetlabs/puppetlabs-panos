require 'spec_helper'
require 'puppet/type/panos_path_monitor'

RSpec.describe 'the panos_path_monitor type' do
  it 'loads' do
    expect(Puppet::Type.type(:panos_path_monitor)).not_to be_nil
  end

  it 'has a base_xpath' do
    expect(Puppet::Type.type(:panos_path_monitor).context.type.definition).to have_key :base_xpath
  end
end
