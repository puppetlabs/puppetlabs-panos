require 'spec_helper'
require 'support/shared_examples'

module Puppet::Provider::PanosNatPolicy; end
require 'puppet/provider/panos_nat_policy/panos_nat_policy'

RSpec.describe Puppet::Provider::PanosNatPolicy::PanosNatPolicy do
  subject(:provider) { described_class.new }

  describe 'munge(entry)' do
    context 'when boolean values are found in the entry' do
      let(:entry) do
        {
          name: 'foo',
          bi_directional: in_value,
        }
      end
      let(:munged_entry) do
        {
          name: 'foo',
          bi_directional: out_value,
        }
      end

      context 'when :bi_directional is `yes`' do
        let(:in_value) { 'Yes' }
        let(:out_value) { true }

        it { expect(provider.munge(entry)).to eq(munged_entry) }
      end
      context 'when :bi_directional is `yes`' do
        let(:in_value) { 'No' }
        let(:out_value) { false }

        it { expect(provider.munge(entry)).to eq(munged_entry) }
      end
    end
    context 'when :source_translation_type is nil' do
      let(:entry) do
        {
          name: 'foo',
          source_translation_type: nil,
        }
      end
      let(:munged_entry) do
        {
          name: 'foo',
          source_translation_type: 'none',
        }
      end

      it { expect(provider.munge(entry)).to eq(munged_entry) }
    end
  end

  describe 'validate_should(should)' do
    context 'When no validation is required' do
      let(:expected_hash) do
        {
          name: 'foo',
          fallback_address_type: 'translated-address',
        }
      end

      it { expect { provider.validate_should(expected_hash) }.not_to raise_error }
    end

    context 'When bi-directional is true and DAT is used' do
      let(:expected_hash) do
        {
          name: 'foo',
          bi_directional: true,
          destination_translated_address: 'DAT adr',
        }
      end

      it { expect { provider.validate_should(expected_hash) }.to raise_error Puppet::ResourceError, %r{rule with both source and destination} }
    end

    context 'When bi-directional is false and DAT is used' do
      let(:expected_hash) do
        {
          name: 'foo',
          bi_directional: false,
          destination_translated_address: 'DAT adr',
        }
      end

      it { expect { provider.validate_should(expected_hash) }.not_to raise_error }
    end

    context 'When the rule has a NAT type of nptv6 and is configured to use dynamic ip in SAT' do
      let(:expected_hash) do
        {
          name: 'foo',
          nat_type: 'nptv6',
          source_translation_type: 'dynamic-ip',
        }
      end

      it { expect { provider.validate_should(expected_hash) }.to raise_error Puppet::ResourceError, %r{Source Address Translation must be used with `nptv6` NAT } }
    end

    context 'When the rule has a NAT type of nptv6 and is configured to use static ip in SAT' do
      let(:expected_hash) do
        {
          name: 'foo',
          nat_type: 'nptv6',
          source_translated_static_address: 'translated-address',
          source_translation_type: 'static-ip',
        }
      end

      it { expect { provider.validate_should(expected_hash) }.not_to raise_error }
    end

    context 'When the fallback is configured to use translated-address, but a fallback_interface is provided' do
      let(:expected_hash) do
        {
          name: 'foo',
          fallback_address_type: 'translated-address',
          fallback_interface: 'tunnel',
        }
      end

      it { expect { provider.validate_should(expected_hash) }.to raise_error Puppet::ResourceError, %r{when the fallback address type is `translated-address`} }
    end

    context 'When the fallback is configured to use translated-address, and no data is provided' do
      let(:expected_hash) do
        {
          name: 'foo',
          fallback_address_type: 'translated-address',
        }
      end

      it { expect { provider.validate_should(expected_hash) }.not_to raise_error }
    end

    context 'When the policy uses static-ip source translation, but is provided static ips' do
      let(:expected_hash) do
        {
          name: 'foo',
          source_translation_type: 'static-ip',
          source_translated_static_address: 'translated-address',
        }
      end

      it { expect { provider.validate_should(expected_hash) }.not_to raise_error }
    end

    context 'When the policy uses static-ip source translation, but is provided no static ips' do
      let(:expected_hash) do
        {
          name: 'foo',
          source_translation_type: 'static-ip',
          source_translated_static_address: nil,
        }
      end

      it { expect { provider.validate_should(expected_hash) }.to raise_error Puppet::ResourceError, %r{You must specify the translated addresses when using Static Ip Source Address Translation} }
    end

    context 'When the fallback is configured to use interface-address, but a fallback-address is provided' do
      let(:expected_hash) do
        {
          name: 'foo',
          fallback_address_type: 'interface-address',
          fallback_address: 'fallback_address',
        }
      end

      it { expect { provider.validate_should(expected_hash) }.to raise_error Puppet::ResourceError, %r{Please do not supply a fallback address when the fallback address type is `interface-address`} }
    end

    context 'When the fallback is configured to use interface-address, and no fallback-address is provided' do
      let(:expected_hash) do
        {
          name: 'foo',
          fallback_address_type: 'interface-address',
        }
      end

      it { expect { provider.validate_should(expected_hash) }.not_to raise_error }
    end
  end

  test_data = [
    {
      desc: 'an example with all attributes',
      attrs: {
        name:                             'Test NAT Policy 1',
        ensure:                           'present',
        description:                      'something interesting',
        tags:                             ['newTag', 'Test Tag'],
        destination:                      ['destAdr', 'destination_adr'],
        destination_interface:            'tunnel',
        destination_translated_address:   'DATadr',
        destination_translated_port:      '5',
        to:                               ['destinationzone', 'destzone'],
        fallback_address_type:            'translated-address',
        fallback_address:                 ['address', 'fallback-adr'],
        source_translated_address:        ['translatedAdr', 'transAdr'],
        source_translation_type:          'dynamic-ip',
        from:                             ['sourcezone', 'source_zone'],
        source:                           ['sourceAdr', 'source_adr'],
        service:                          'ftp',
        nat_type:                         'ipv4',
      },
      xml: '<entry name="Test NAT Policy 1">
              <source-translation>
                <dynamic-ip>
                  <fallback>
                    <translated-address>
                      <member>address</member>
                      <member>fallback-adr</member>
                    </translated-address>
                  </fallback>
                  <translated-address>
                    <member>translatedAdr</member>
                    <member>transAdr</member>
                  </translated-address>
                </dynamic-ip>
              </source-translation>
              <to>
                <member>destinationzone</member>
                <member>destzone</member>
              </to>
              <destination-translation>
                <translated-port>5</translated-port>
                <translated-address>DATadr</translated-address>
              </destination-translation>
              <from>
                <member>sourcezone</member>
                <member>source_zone</member>
              </from>
              <source>
                <member>sourceAdr</member>
                <member>source_adr</member>
              </source>
              <destination>
                <member>destAdr</member>
                <member>destination_adr</member>
              </destination>
              <tag>
                <member>newTag</member>
                <member>Test Tag</member>
              </tag>
              <service>ftp</service>
              <description>something interesting</description>
              <to-interface>tunnel</to-interface>
              <nat-type>ipv4</nat-type>
            </entry>',
    },
    {
      desc: 'an example with only essential attributes',
      attrs: {
        name:        'Test NAT Policy 2',
        ensure:      'present',
        to:          ['destinationzone', 'destzone'],
        from:        ['any'],
        source:      ['any'],
        destination: ['any'],
        service:     'any',
      },
      xml: '<entry name="Test NAT Policy 2">
              <to>
                <member>destinationzone</member>
                <member>destzone</member>
              </to>
              <from>
                <member>any</member>
              </from>
              <source>
                <member>any</member>
              </source>
              <destination>
                <member>any</member>
              </destination>
              <service>any</service>
            </entry>',
    },
    {
      desc: 'an example using Dynamic IP SAT',
      attrs: {
        name:                      'Test NAT Policy 3',
        ensure:                    'present',
        source_translation_type:   'dynamic-ip',
        source_translated_address: ['translatedAdr', 'transAdr'],
        from:                      ['sourcezone', 'source_zone'],
        source:                    ['sourceAdr', 'source_adr'],
        to:                        ['destinationzone', 'destzone'],
        destination:               ['destAdr', 'destination_adr'],
        destination_interface:     'any',
        service:                   'any',
        nat_type:                  'ipv4',
      },
      xml: '<entry name="Test NAT Policy 3">
              <source-translation>
                <dynamic-ip>
                  <translated-address>
                    <member>translatedAdr</member>
                    <member>transAdr</member>
                  </translated-address>
                </dynamic-ip>
              </source-translation>
              <to>
                <member>destinationzone</member>
                <member>destzone</member>
              </to>
              <from>
                <member>sourcezone</member>
                <member>source_zone</member>
              </from>
              <source>
                <member>sourceAdr</member>
                <member>source_adr</member>
              </source>
              <destination>
                <member>destAdr</member>
                <member>destination_adr</member>
              </destination>
              <service>any</service>
              <to-interface>any</to-interface>
              <nat-type>ipv4</nat-type>
            </entry>',
    },
    {
      desc: 'an example using Static IP SAT',
      attrs: {
        name:                             'Test NAT Policy 4',
        ensure:                           'present',
        source_translation_type:          'static-ip',
        bi_directional:                   true,
        source_translated_static_address: 'SAT-adr',
        from:                             ['sourcezone', 'source_zone'],
        source:                           ['sourceAdr', 'source_adr'],
        to:                               ['destinationzone', 'destzone'],
        destination:                      ['destAdr', 'destination_adr'],
        destination_interface:            'any',
        service:                          'any',
        nat_type:                         'ipv4',
      },
      xml: '<entry name="Test NAT Policy 4">
              <source-translation>
                <static-ip>
                  <bi-directional>yes</bi-directional>
                  <translated-address>SAT-adr</translated-address>
                </static-ip>
              </source-translation>
              <to>
                <member>destinationzone</member>
                <member>destzone</member>
              </to>
              <from>
                <member>sourcezone</member>
                <member>source_zone</member>
              </from>
              <source>
                <member>sourceAdr</member>
                <member>source_adr</member>
              </source>
              <destination>
                <member>destAdr</member>
                <member>destination_adr</member>
              </destination>
              <service>any</service>
              <to-interface>any</to-interface>
              <nat-type>ipv4</nat-type>
            </entry>',
    },
    {
      desc: 'an example using Dynamic IP and Port SAT',
      attrs: {
        name:                      'Test NAT Policy 5',
        ensure:                    'present',
        source_translation_type:   'dynamic-ip-and-port',
        source_translated_address: ['translatedAdr', 'transAdr'],
        from:                      ['sourcezone', 'source_zone'],
        to:                        ['destinationzone', 'destzone'],
        source:                    ['sourceAdr', 'source_adr'],
        destination:               ['destAdr', 'destination_adr'],
        service:                   'any',
        nat_type:                  'ipv4',
        destination_interface:     'any',
      },
      xml: '<entry name="Test NAT Policy 5">
              <source-translation>
                <dynamic-ip-and-port>
                  <translated-address>
                    <member>translatedAdr</member>
                    <member>transAdr</member>
                  </translated-address>
                </dynamic-ip-and-port>
              </source-translation>
              <to>
                <member>destinationzone</member>
                <member>destzone</member>
              </to>
              <from>
                <member>sourcezone</member>
                <member>source_zone</member>
              </from>
              <source>
                <member>sourceAdr</member>
                <member>source_adr</member>
              </source>
              <destination>
                <member>destAdr</member>
                <member>destination_adr</member>
              </destination>
              <service>any</service>
              <to-interface>any</to-interface>
              <nat-type>ipv4</nat-type>
            </entry>',
    },
    {
      desc: 'an example using translated address Dynamic IP/Port Fallback',
      attrs: {
        name:                      'Test NAT Policy 6',
        ensure:                    'present',
        source_translation_type:   'dynamic-ip',
        source_translated_address: ['translatedAdr', 'transAdr'],
        fallback_address_type:     'translated-address',
        fallback_address:          ['address', 'fallback-adr'],
        from:                      ['sourcezone', 'source_zone'],
        to:                        ['destinationzone', 'destzone'],
        source:                    ['sourceAdr', 'source_adr'],
        destination:               ['destAdr', 'destination_adr'],
        service:                   'any',
        nat_type:                  'ipv4',
      },
      xml: '<entry name="Test NAT Policy 6">
              <source-translation>
                <dynamic-ip>
                  <fallback>
                    <translated-address>
                    <member>address</member>
                    <member>fallback-adr</member>
                    </translated-address>
                  </fallback>
                  <translated-address>
                    <member>translatedAdr</member>
                    <member>transAdr</member>
                  </translated-address>
                </dynamic-ip>
              </source-translation>
              <to>
                <member>destinationzone</member>
                <member>destzone</member>
              </to>
              <from>
                <member>sourcezone</member>
                <member>source_zone</member>
              </from>
              <source>
                <member>sourceAdr</member>
                <member>source_adr</member>
              </source>
              <destination>
                <member>destAdr</member>
                <member>destination_adr</member>
              </destination>
              <service>any</service>
              <nat-type>ipv4</nat-type>
            </entry>',
    },
    {
      desc: 'an example using Destination Address Translation',
      attrs: {
        name:                           'Test NAT Policy 7',
        ensure:                         'present',
        destination_translated_address: 'DATadr',
        destination_translated_port:    '5',
        from:                           ['sourcezone', 'source_zone'],
        to:                             ['destinationzone', 'destzone'],
        source:                         ['sourceAdr', 'source_adr'],
        destination:                    ['destAdr', 'destination_adr'],
        service:                        'any',
        nat_type:                       'ipv4',
      },
      xml: '<entry name="Test NAT Policy 7">
            <to>
              <member>destinationzone</member>
              <member>destzone</member>
            </to>
            <destination-translation>
              <translated-port>5</translated-port>
              <translated-address>DATadr</translated-address>
            </destination-translation>
            <from>
              <member>sourcezone</member>
              <member>source_zone</member>
            </from>
            <source>
              <member>sourceAdr</member>
              <member>source_adr</member>
            </source>
            <destination>
              <member>destAdr</member>
              <member>destination_adr</member>
            </destination>
              <service>any</service>
              <nat-type>ipv4</nat-type>
            </entry>',
    },
    {
      desc: 'an example using interface address as a fallback',
      attrs: {
        name:                       'Test NAT Policy 8',
        ensure:                     'present',
        source_translation_type:    'dynamic-ip',
        source_translated_address:  ['translatedAdr', 'transAdr'],
        fallback_address_type:      'interface-address',
        fallback_interface:         'tunnel.10',
        fallback_interface_ip:      '10.10.10.10',
        fallback_interface_ip_type: 'ip',
        from:                       ['sourcezone', 'source_zone'],
        to:                         ['destinationzone', 'destzone'],
        source:                              ['sourceAdr', 'source_adr'],
        destination:                         ['destAdr', 'destination_adr'],
        service:                    'any',
        nat_type:                   'ipv4',
      },
      xml: '<entry name="Test NAT Policy 8">
              <source-translation>
                <dynamic-ip>
                  <fallback>
                    <interface-address>
                      <interface>tunnel.10</interface>
                      <ip>10.10.10.10</ip>
                    </interface-address>
                  </fallback>
                  <translated-address>
                    <member>translatedAdr</member>
                    <member>transAdr</member>
                  </translated-address>
                </dynamic-ip>
              </source-translation>
              <to>
                <member>destinationzone</member>
                <member>destzone</member>
              </to>
              <from>
                <member>sourcezone</member>
                <member>source_zone</member>
              </from>
              <source>
                <member>sourceAdr</member>
                <member>source_adr</member>
              </source>
              <destination>
                <member>destAdr</member>
                <member>destination_adr</member>
              </destination>
              <service>any</service>
              <nat-type>ipv4</nat-type>
            </entry>',
    },
    {
      desc: 'an example using using interface address',
      attrs: {
        name:                    'Test NAT Policy 9',
        ensure:                  'present',
        source_translation_type: 'dynamic-ip-and-port',
        sat_interface:           'tunnel.10',
        sat_interface_ip:        '10.10.10.10',
        from:                    ['sourcezone', 'source_zone'],
        to:                      ['destinationzone', 'destzone'],
        source:                  ['sourceAdr', 'source_adr'],
        destination:             ['destAdr', 'destination_adr'],
        service:                 'any',
        nat_type:                'ipv4',
      },
      xml: '<entry name="Test NAT Policy 9">
              <source-translation>
                <dynamic-ip-and-port>
                  <interface-address>
                    <ip>10.10.10.10</ip>
                    <interface>tunnel.10</interface>
                  </interface-address>
                </dynamic-ip-and-port>
              </source-translation>
              <to>
                <member>destinationzone</member>
                <member>destzone</member>
              </to>
              <from>
                <member>sourcezone</member>
                <member>source_zone</member>
              </from>
              <source>
                <member>sourceAdr</member>
                <member>source_adr</member>
              </source>
              <destination>
                <member>destAdr</member>
                <member>destination_adr</member>
              </destination>
              <service>any</service>
              <nat-type>ipv4</nat-type>
            </entry>',
    },
    {
      desc: 'An example with both Source Address Translation and Destination Address Translation',
      attrs: {
        name:                             'New Test Policy 10',
        ensure:                           'present',
        description:                      'Description',
        nat_type:                         'nat64',
        from:                             ['sourcezone', 'source_zone'],
        to:                               ['destinationzone', 'destzone'],
        destination_interface:            'vlan',
        service:                          'ftp',
        source:                           ['sourceAdr', 'source_adr'],
        destination:                      ['destAdr', 'destination_adr'],
        source_translation_type:          'static-ip',
        bi_directional:                   false,
        destination_translated_address:   'DAT adr',
        source_translated_static_address: 'SAT adr',
        destination_translated_port:      '7',
        tags:                             ['newTag', 'Test Tag'],
      },
      xml: '<entry name="New Test Policy 10">
              <source-translation>
                <static-ip>
                  <translated-address>SAT adr</translated-address>
                </static-ip>
              </source-translation>
              <to>
                <member>destinationzone</member>
                <member>destzone</member>
              </to>
              <destination-translation>
                <translated-port>7</translated-port>
                <translated-address>DAT adr</translated-address>
              </destination-translation>
              <from>
                <member>sourcezone</member>
                <member>source_zone</member>
              </from>
              <source>
                <member>sourceAdr</member>
                <member>source_adr</member>
              </source>
              <destination>
                <member>destAdr</member>
                <member>destination_adr</member>
              </destination>
              <tag>
                <member>newTag</member>
                <member>Test Tag</member>
              </tag>
              <service>ftp</service>
              <description>Description</description>
              <to-interface>vlan</to-interface>
              <nat-type>nat64</nat-type>
            </entry>',
    },
    {
      desc: 'a disabled example using Static IP SAT',
      attrs: {
        name:                             'Test NAT Policy 11',
        ensure:                           'present',
        source_translation_type:          'static-ip',
        bi_directional:                   true,
        source_translated_static_address: 'SAT-adr',
        from:                             ['sourcezone', 'source_zone'],
        source:                           ['sourceAdr', 'source_adr'],
        to:                               ['destinationzone', 'destzone'],
        destination:                      ['destAdr', 'destination_adr'],
        destination_interface:            'any',
        service:                          'any',
        nat_type:                         'ipv4',
        disabled:                         true,
      },
      xml: '<entry name="Test NAT Policy 11">
              <source-translation>
                <static-ip>
                  <bi-directional>yes</bi-directional>
                  <translated-address>SAT-adr</translated-address>
                </static-ip>
              </source-translation>
              <to>
                <member>destinationzone</member>
                <member>destzone</member>
              </to>
              <from>
                <member>sourcezone</member>
                <member>source_zone</member>
              </from>
              <source>
                <member>sourceAdr</member>
                <member>source_adr</member>
              </source>
              <destination>
                <member>destAdr</member>
                <member>destination_adr</member>
              </destination>
              <service>any</service>
              <to-interface>any</to-interface>
              <nat-type>ipv4</nat-type>
              <disabled>yes</disabled>
            </entry>',
    },
    {
      desc: 'an example using using SAT interface only',
      attrs: {
        name:                    'Test NAT Policy 12',
        ensure:                  'present',
        source_translation_type: 'dynamic-ip-and-port',
        sat_interface:           'tunnel.10',
        from:                    ['sourcezone', 'source_zone'],
        to:                      ['destinationzone', 'destzone'],
        source:                  ['sourceAdr', 'source_adr'],
        destination:             ['destAdr', 'destination_adr'],
        service:                 'any',
        nat_type:                'ipv4',
      },
      xml: '<entry name="Test NAT Policy 12">
              <source-translation>
                <dynamic-ip-and-port>
                  <interface-address>
                    <interface>tunnel.10</interface>
                  </interface-address>
                </dynamic-ip-and-port>
              </source-translation>
              <to>
                <member>destinationzone</member>
                <member>destzone</member>
              </to>
              <from>
                <member>sourcezone</member>
                <member>source_zone</member>
              </from>
              <source>
                <member>sourceAdr</member>
                <member>source_adr</member>
              </source>
              <destination>
                <member>destAdr</member>
                <member>destination_adr</member>
              </destination>
              <service>any</service>
              <nat-type>ipv4</nat-type>
            </entry>',
    },
  ]

  include_examples 'xml_from_should(name, should)', test_data, described_class.new
end
