require 'spec_helper'
require 'puppet/type/panos_ipv6_static_route'

RSpec.describe 'the panos_ipv6_static_route type' do
  it 'loads' do
    expect(Puppet::Type.type(:panos_ipv6_static_route)).not_to be_nil
  end

  it 'has a base_xpath' do
    expect(Puppet::Type.type(:panos_ipv6_static_route).context.type.definition).to have_key :base_xpath
  end

  context 'when `route` exceeds 31 characters' do
    let(:route) { 'vr name/this is longer than 31 character' }

    it 'throws an error' do
      expect(route.length).to eq 40
      expect {
        Puppet::Type.type(:panos_ipv6_static_route).new(
          name: route,
          vr_name: 'vr name',
        )
      }.to raise_error Puppet::ResourceError
    end
  end
  context 'when `route` does not exceed 31 characters' do
    let(:route) { 'vr name /exactly 31 characters ' }

    it 'does not throw an error' do
      expect(route.length).to eq 31
      expect {
        Puppet::Type.type(:panos_ipv6_static_route).new(
          name: route,
          vr_name: 'vr name ',
        )
      }.not_to raise_error
    end
  end
end
