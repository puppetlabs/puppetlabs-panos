# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/panos_zone'

RSpec.describe 'the panos_zone type' do
  it 'loads' do
    expect(Puppet::Type.type(:panos_zone)).not_to be_nil
  end

  it 'has a base_xpath' do
    expect(Puppet::Type.type(:panos_zone).context.type.definition).to have_key :base_xpath
  end

  context 'when `name` exceeds 31 characters' do
    let(:name) { 'this is longer than 31 character' }

    it 'throws an error' do
      expect(name.length).to eq 32

      expect {
        Puppet::Type.type(:panos_zone).new(
          name: name,
        )
      }.to raise_error Puppet::ResourceError
    end
  end

  context 'when `name` does not exceed 31 characters' do
    let(:name) { 'the exactly 31 character string' }

    it 'does not throw an error' do
      expect(name.length).to eq 31

      expect {
        Puppet::Type.type(:panos_zone).new(
          name: name,
        )
      }.not_to raise_error
    end
  end
end
