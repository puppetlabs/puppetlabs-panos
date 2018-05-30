require 'spec_helper'

# TODO: needs some cleanup/helper to avoid this misery
module Puppet::Provider::PanosAddress; end
require 'puppet/provider/panos_address/panos_address'

RSpec.describe Puppet::Provider::PanosAddress::PanosAddress do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Panos::Device', 'device') }
  let(:typedef) { instance_double('Puppet::ResourceApi::TypeDefinition', 'typedef') }
  let(:example_data) do
    REXML::Document.new <<EOF
    <response status="success" code="19">
      <result total-count="1" count="1">
        <entry name="address">
          <ip-netmask>1.2.3.4/30</ip-netmask>
          <tag>
            <member>a</member>
          </tag>
          <description>some address</description>
        </entry>
        <entry name="address-1">
          <tag>
            <member>a</member>
          </tag>
          <description>some address</description>
          <ip-range>10.0.0.1-10.0.0.4</ip-range>
        </entry>
        <entry name="address-2">
          <tag>
            <member>a</member>
          </tag>
          <description>some address</description>
          <fqdn>example.net</fqdn>
        </entry>
      </result>
    </response>
EOF
  end

  before(:each) do
    allow(context).to receive(:device).with(no_args).and_return(device)
    allow(context).to receive(:type).with(no_args).and_return(typedef)
  end

  describe '#get' do
    it 'processes resources' do
      allow(typedef).to receive(:definition).with(no_args).and_return(base_xpath: 'some xpath')
      allow(typedef).to receive(:attributes).with(no_args).and_return(description: { xpath: 'description' },
                                                                      ip_netmask: { xpath: 'ip-netmask' },
                                                                      ip_range: { xpath: 'ip-range' },
                                                                      fqdn: { xpath: 'fqdn' },
                                                                      tags: {})
      allow(device).to receive(:get_config).with('some xpath').and_return(example_data)

      expect(provider.get(context)).to eq [
        {
          name: 'address',
          ensure: 'present',
          description: 'some address',
          ip_netmask: '1.2.3.4/30',
          ip_range: nil,
          fqdn: nil,
          tags: ['a'],
        },
        {
          name: 'address-1',
          ensure: 'present',
          description: 'some address',
          ip_netmask: nil,
          ip_range: '10.0.0.1-10.0.0.4',
          fqdn: nil,
          tags: ['a'],
        },
        {
          name: 'address-2',
          ensure: 'present',
          description: 'some address',
          ip_netmask: nil,
          ip_range: nil,
          fqdn: 'example.net',
          tags: ['a'],
        },
      ]
    end
  end

  describe 'create(context, name, should)' do
    it 'creates the resource' do
      expect(context).to receive(:notice).with(%r{\ACreating 'a'})

      provider.create(context, 'a', name: 'a', ensure: 'present')
    end
  end

  describe 'update(context, name, should)' do
    it 'updates the resource' do
      expect(context).to receive(:notice).with(%r{\AUpdating 'foo'})

      provider.update(context, 'foo', name: 'foo', ensure: 'present')
    end
  end

  describe 'delete(context, name, should)' do
    it 'deletes the resource' do
      expect(context).to receive(:notice).with(%r{\ADeleting 'foo'})

      provider.delete(context, 'foo')
    end
  end
end
