require 'spec_helper'
require 'puppet/type/panos_security_policy_rule'

RSpec.describe 'the panos_security_policy_rule type' do
  it 'loads' do
    expect(Puppet::Type.type(:panos_security_policy_rule)).not_to be_nil
  end

  it 'has a base_xpath' do
    expect(Puppet::Type.type(:panos_security_policy_rule).context.type.definition).to have_key :base_xpath
  end
end
