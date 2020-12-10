# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/panos_admin'

RSpec.describe 'the panos_admin type' do
  it 'loads' do
    expect(Puppet::Type.type(:panos_admin)).not_to be_nil
  end

  it 'has a base_xpath' do
    expect(Puppet::Type.type(:panos_admin).context.type.definition).to have_key :base_xpath
  end

  context 'when `name` exceeds 31 characters' do
    let(:name) { 'this_is_longer_than_31_character' }

    it 'throws an error' do
      expect(name.length).to eq 32

      expect {
        Puppet::Type.type(:panos_admin).new(
          name: name,
        )
      }.to raise_error Puppet::ResourceError
    end
  end

  context 'when `name` does not exceed 31 characters' do
    let(:name) { 'the_exactly_31_character_string' }

    it 'does not throw an error' do
      expect(name.length).to eq 31

      expect {
        Puppet::Type.type(:panos_admin).new(
          name: name,
        )
      }.not_to raise_error
    end
  end

  context 'when `name` contains a space' do
    let(:name) { 'the exactly 31 character string' }

    it 'throws an error' do
      expect {
        Puppet::Type.type(:panos_admin).new(
          name: name,
        )
      }.to raise_error Puppet::ResourceError
    end
  end
end
