# frozen_string_literal: true

require 'spec_helper'
require 'support/shared_examples'

module Puppet::Provider::PanosAddress; end
require 'puppet/provider/panos_address/panos_address'

RSpec.describe Puppet::Provider::PanosAddress::PanosAddress do
  subject(:provider) { described_class.new }

  describe 'validate_should(should)' do
    context 'when ip_netmask is provided' do
      let(:should_hash) do
        {
          name: 'address',
          ensure: 'present',
          description: 'some address',
          ip_netmask: '1.2.3.4/30',
          tags: ['a'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when ip_range is provided' do
      let(:should_hash) do
        {
          name: 'address-1',
          ensure: 'present',
          description: 'some address',
          ip_range: '10.0.0.1-10.0.0.4',
          tags: ['a'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when fqdn is provided' do
      let(:should_hash) do
        {
          name: 'address-2',
          ensure: 'present',
          description: 'some address',
          fqdn: 'example.net',
          tags: ['a'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when ip_netmask and ip_range are provided' do
      let(:should_hash) do
        {
          name: 'address',
          ensure: 'present',
          description: 'some address',
          ip_netmask: '1.2.3.4/30',
          ip_range: '10.0.0.1-10.0.0.4',
          tags: ['a'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{ip_netmask, ip_range, and fqdn are mutually exclusive fields} }
    end
    context 'when ip_netmask and fqdn are provided' do
      let(:should_hash) do
        {
          name: 'address',
          ensure: 'present',
          description: 'some address',
          ip_netmask: '1.2.3.4/30',
          fqdn: 'example.net',
          tags: ['a'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{ip_netmask, ip_range, and fqdn are mutually exclusive fields} }
    end
    context 'when ip_range and fqdn are provided' do
      let(:should_hash) do
        {
          name: 'address',
          ensure: 'present',
          description: 'some address',
          ip_range: '10.0.0.1-10.0.0.4',
          fqdn: 'example.net',
          tags: ['a'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{ip_netmask, ip_range, and fqdn are mutually exclusive fields} }
    end
    context 'when ip_range, ip_netmask, or fqdn is not provided' do
      let(:should_hash) do
        {
          name: 'address-2',
          ensure: 'present',
          description: 'some address',
          tags: ['a'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{One of the following attributes must be provided: ip_netmask, ip_range, or fqdn} }
    end
  end

  test_data = [
    {
      desc:   'an example containing netmask_address',
      attrs: {
        name:         'netmask_address',
        ensure:       'present',
        description:  'some address',
        ip_netmask:   '1.2.3.4/30',
        tags:         ['a', 'b'],
      },
      xml:  '<entry name="netmask_address">
              <description>some address</description>
              <ip-netmask>1.2.3.4/30</ip-netmask>
              <tag>
                <member>a</member>
                <member>b</member>
               </tag>
            </entry>',
    },
    {
      desc:   'an example containing range_address',
      attrs: {
        name:         'range_address',
        ensure:       'present',
        description:  'some address',
        ip_range:     '10.0.0.1-10.0.0.4',
        tags:         ['a'],
      },
      xml:    '<entry name="range_address">
                <description>some address</description>
                <ip-range>10.0.0.1-10.0.0.4</ip-range>
                <tag>
                  <member>a</member>
                </tag>
              </entry>',
    },
    {
      desc: 'an example containing fqdn_address',
      attrs: {
        name:         'fqdn_address',
        ensure:       'present',
        description:  'some address',
        fqdn:         'example.net',
        tags:         [],
      },
      xml:  '<entry name="fqdn_address">
              <description>some address</description>
              <fqdn>example.net</fqdn>
              <tag></tag>
            </entry>',
    },
  ]

  include_examples 'xml_from_should(name, should)', test_data, described_class.new
end
