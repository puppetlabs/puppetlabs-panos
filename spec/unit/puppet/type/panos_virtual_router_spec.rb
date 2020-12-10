# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/panos_virtual_router'

RSpec.describe 'the panos_virtual_router type' do
  it 'loads' do
    expect(Puppet::Type.type(:panos_virtual_router)).not_to be_nil
  end

  it 'has a base_xpath' do
    expect(Puppet::Type.type(:panos_virtual_router).context.type.definition).to have_key :base_xpath
  end

  context 'when `name` exceeds 31 characters' do
    let(:router) { 'this is longer than 31 character' }

    it 'throws an error' do
      expect(router.length).to eq 32
      expect {
        Puppet::Type.type(:panos_virtual_router).new(
          name: router,
        )
      }.to raise_error Puppet::ResourceError
    end
  end
  context 'when `route` does not exceed 31 characters' do
    let(:router) { 'the exactly 31 character string' }

    it 'does not throw an error' do
      expect(router.length).to eq 31
      expect {
        Puppet::Type.type(:panos_virtual_router).new(
          name: router,
        )
      }.not_to raise_error
    end
  end
end
