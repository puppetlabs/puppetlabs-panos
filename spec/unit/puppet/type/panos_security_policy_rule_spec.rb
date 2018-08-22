require 'spec_helper'
require 'puppet/type/panos_security_policy_rule'

RSpec.describe 'the panos_security_policy_rule type' do
  it 'loads' do
    expect(Puppet::Type.type(:panos_security_policy_rule)).not_to be_nil
  end

  it 'has a base_xpath' do
    expect(Puppet::Type.type(:panos_security_policy_rule).context.type.definition).to have_key :base_xpath
  end

  context 'when `name` exceeds 63 characters' do
    let(:name) { 'longer string exceeding the 63 character limit on a PAN-OS 8.1.2' }

    it 'throws an error' do
      expect(name.length).to eq 64

      expect {
        Puppet::Type.type(:panos_security_policy_rule).new(
          name: name,
        )
      }.to raise_error Puppet::ResourceError
    end
  end

  context 'when `name` does not exceed 63 characters' do
    let(:name) { 'the shorter string within a 63 character limit for PAN-OS 8.1.2' }

    it 'does not throw an error' do
      expect(name.length).to eq 63

      expect {
        Puppet::Type.type(:panos_security_policy_rule).new(
          name: name,
        )
      }.not_to raise_error
    end
  end
end
