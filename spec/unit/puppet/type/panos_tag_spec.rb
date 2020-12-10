# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/panos_tag'

RSpec.describe 'the panos_tag type' do
  it 'loads' do
    expect(Puppet::Type.type(:panos_tag)).not_to be_nil
  end

  it 'has a base_xpath' do
    expect(Puppet::Type.type(:panos_tag).context.type.definition).to have_key :base_xpath
  end

  context 'when `name` exceeds 127 characters' do
    let(:name) { 'longer string exceeding the 127 character limit on a PAN-OS 8.1.0 for PANOS tag entries as they are restricted to 127 characters' }

    it 'throws an error' do
      expect(name.length).to eq 128

      expect {
        Puppet::Type.type(:panos_tag).new(
          name: name,
        )
      }.to raise_error Puppet::ResourceError
    end
  end

  context 'when `name` does not exceed 31 characters' do
    let(:name) { 'shorter string within the 127 character limit set on a PAN-OS 8.1.0 for PANOS tag entries as it is restricted to 127 characters' }

    it 'does not throw an error' do
      expect(name.length).to eq 127

      expect {
        Puppet::Type.type(:panos_tag).new(
          name: name,
        )
      }.not_to raise_error
    end
  end
end
