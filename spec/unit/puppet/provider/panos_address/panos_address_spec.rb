require 'spec_helper'
require 'support/matchers/have_xml'

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
    allow(context).to receive(:notice)
    allow(typedef).to receive(:definition).with(no_args).and_return(base_xpath: 'some xpath')
  end

  describe '#get' do
    it 'processes resources' do
      allow(typedef).to receive(:attributes).with(no_args).and_return(description: { xpath: 'description' },
                                                                      ip_netmask: { xpath: 'ip-netmask' },
                                                                      ip_range: { xpath: 'ip-range' },
                                                                      fqdn: { xpath: 'fqdn' },
                                                                      tags: {})
      allow(device).to receive(:get_config).with('some xpath/entry').and_return(example_data)

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
    before(:each) do
      allow(device).to receive(:set_config)
    end

    it 'logs the call' do
      expect(context).to receive(:notice).with(%r{\ACreating 'a'})
      provider.create(context, 'a', name: 'a', ensure: 'present', ip_netmask: 'netmask')
    end

    it 'uses the correct base structure' do
      expect(device).to receive(:set_config).with('some xpath', instance_of(REXML::Document)) do |_xpath, doc|
        expect(doc).to have_xml("entry[@name='a']")
      end
      provider.create(context, 'a', name: 'a', ensure: 'present')
    end

    context 'when providing a netmask' do
      it 'creates the resource' do
        expect(device).to receive(:set_config).with('some xpath', instance_of(REXML::Document)) do |_xpath, doc|
          expect(doc).to have_xml('entry/ip-netmask', 'netmask')
          expect(doc).not_to have_xml('entry/ip-range')
          expect(doc).not_to have_xml('entry/fqdn')
        end

        provider.create(context, 'a', name: 'a', ensure: 'present', ip_netmask: 'netmask')
      end
    end

    context 'when providing a range' do
      it 'creates the resource' do
        expect(device).to receive(:set_config).with('some xpath', instance_of(REXML::Document)) do |_xpath, doc|
          expect(doc).not_to have_xml('entry/ip-netmask')
          expect(doc).to have_xml('entry/ip-range', 'range')
          expect(doc).not_to have_xml('entry/fqdn')
        end

        provider.create(context, 'a', name: 'a', ensure: 'present', ip_range: 'range')
      end
    end

    context 'when providing an fqdn' do
      it 'creates the resource' do
        expect(device).to receive(:set_config).with('some xpath', instance_of(REXML::Document)) do |_xpath, doc|
          expect(doc).not_to have_xml('entry/ip-netmask')
          expect(doc).not_to have_xml('entry/ip-range')
          expect(doc).to have_xml('entry/fqdn', 'example.com')
        end

        provider.create(context, 'a', name: 'a', ensure: 'present', fqdn: 'example.com')
      end
    end

    context 'with tags' do
      it 'creates the resource' do
        expect(device).to receive(:set_config).with('some xpath', instance_of(REXML::Document)) do |_xpath, doc|
          expect(doc).to have_xml('entry/tag/member', 'a')
          expect(doc).to have_xml('entry/tag/member', 'b')
        end

        provider.create(context, 'a', name: 'a', ensure: 'present', fqdn: 'example.com', tags: ['a', 'b'])
      end
    end

    context 'with a description' do
      it 'creates the resource' do
        expect(device).to receive(:set_config).with('some xpath', instance_of(REXML::Document)) do |_xpath, doc|
          expect(doc).to have_xml('entry/description', 'help')
        end

        provider.create(context, 'a', name: 'a', ensure: 'present', fqdn: 'example.com', description: 'help')
      end
    end
  end

  describe 'update(context, name, should)' do
    before(:each) do
      allow(device).to receive(:edit_config)
    end

    it 'logs the call' do
      expect(context).to receive(:notice).with(%r{\AUpdating 'foo'})
      provider.update(context, 'foo', name: 'foo', ensure: 'present')
    end

    it 'uses the correct base structure' do
      expect(device).to receive(:edit_config).with("some xpath/entry[@name='foo']", instance_of(REXML::Document)) do |_xpath, doc|
        expect(doc).to have_xml("entry[@name='foo']")
      end
      provider.update(context, 'foo', name: 'foo', ensure: 'present')
    end

    context 'when providing a netmask' do
      it 'updates the resource' do
        expect(device).to receive(:edit_config).with("some xpath/entry[@name='foo']", instance_of(REXML::Document)) do |_xpath, doc|
          expect(doc).to have_xml('entry/ip-netmask', 'netmask')
          expect(doc).not_to have_xml('entry/ip-range')
          expect(doc).not_to have_xml('entry/fqdn')
        end

        provider.update(context, 'foo', name: 'foo', ensure: 'present', ip_netmask: 'netmask')
      end
    end

    context 'when providing a range' do
      it 'updates the resource' do
        expect(device).to receive(:edit_config).with("some xpath/entry[@name='foo']", instance_of(REXML::Document)) do |_xpath, doc|
          expect(doc).not_to have_xml('entry/ip-netmask')
          expect(doc).to have_xml('entry/ip-range', 'range')
          expect(doc).not_to have_xml('entry/fqdn')
        end

        provider.update(context, 'foo', name: 'foo', ensure: 'present', ip_range: 'range')
      end
    end

    context 'when providing an fqdn' do
      it 'updates the resource' do
        expect(device).to receive(:edit_config).with("some xpath/entry[@name='foo']", instance_of(REXML::Document)) do |_xpath, doc|
          expect(doc).not_to have_xml('entry/ip-netmask')
          expect(doc).not_to have_xml('entry/ip-range')
          expect(doc).to have_xml('entry/fqdn', 'example.com')
        end

        provider.update(context, 'foo', name: 'foo', ensure: 'present', fqdn: 'example.com')
      end
    end

    context 'with tags' do
      it 'updates the resource' do
        expect(device).to receive(:edit_config).with("some xpath/entry[@name='foo']", instance_of(REXML::Document)) do |_xpath, doc|
          expect(doc).to have_xml('entry/tag/member', 'a')
          expect(doc).to have_xml('entry/tag/member', 'b')
        end

        provider.update(context, 'foo', name: 'foo', ensure: 'present', fqdn: 'example.com', tags: ['a', 'b'])
      end
    end

    context 'with a description' do
      it 'creates the resource' do
        expect(device).to receive(:edit_config).with("some xpath/entry[@name='foo']", instance_of(REXML::Document)) do |_xpath, doc|
          expect(doc).to have_xml('entry/description', 'help')
        end

        provider.update(context, 'foo', name: 'foo', ensure: 'present', fqdn: 'example.com', description: 'help')
      end
    end
  end

  describe 'delete(context, name, should)' do
    before(:each) do
      allow(device).to receive(:delete_config)
    end

    it 'logs the call' do
      expect(context).to receive(:notice).with(%r{\ADeleting 'foo'})
      provider.delete(context, 'foo')
    end

    it 'deletes the resource' do
      expect(device).to receive(:delete_config).with("some xpath/entry[@name='foo']")

      provider.delete(context, 'foo')
    end
  end
end
