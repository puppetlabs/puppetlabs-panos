require 'spec_helper'
require 'support/shared_examples'
require 'puppet/type/panos_security_policy_rule'

RSpec.describe 'the panos_security_policy_rule type' do
  it 'loads' do
    expect(Puppet::Type.type(:panos_security_policy_rule)).not_to be_nil
  end

  it 'has a base_xpath' do
    expect(Puppet::Type.type(:panos_security_policy_rule).context.type.definition).to have_key :base_xpath
  end

  include_examples '`name` exceeds 63 characters', :panos_security_policy_rule

  include_examples '`name` does not exceed 63 characters', :panos_security_policy_rule
end
