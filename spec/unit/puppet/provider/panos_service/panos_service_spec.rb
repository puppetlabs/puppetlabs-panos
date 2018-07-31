require 'spec_helper'
require 'support/shared_examples'

module Puppet::Provider::PanosService; end
require 'puppet/provider/panos_service/panos_service'

RSpec.describe Puppet::Provider::PanosService::PanosService do
  subject(:provider) { described_class.new }

  describe 'validate_should(should)' do
    context 'when src_port port is provided' do
      let(:should_hash) do
        {
          name: 'service1',
          ensure: 'present',
          description: 'example service',
          protocol: 'tcp',
          src_port: '2222',
          tags: ['tag1', 'tag2'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when is dest_port port is provided' do
      let(:should_hash) do
        {
          name: 'service1',
          ensure: 'present',
          description: 'example service',
          protocol: 'tcp',
          dest_port: '8888,8881,8882',
          tags: ['tag1', 'tag2'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when is dest_port and src_port port is provided' do
      let(:should_hash) do
        {
          name: 'service1',
          ensure: 'present',
          description: 'example service',
          protocol: 'tcp',
          dest_port: '8888,8881,8882',
          src_port: '2222',
          tags: ['tag1', 'tag2'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when neither src_port or dest_port port is provided' do
      let(:should_hash) do
        {
          name: 'service1',
          ensure: 'present',
          description: 'example service',
          protocol: 'tcp',
          tags: ['tag1', 'tag2'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{`src_port` or `dest_port` must be provided} }
    end
  end

  test_data = [
    {
      desc: 'a UDP example with destination and source ports specified',
      attrs: {
        name:         'everything udp',
        ensure:       'present',
        description:  'abc',
        protocol:     'udp',
        dest_port:    '8888,8881,8882',
        src_port:     '1234,3214,5432',
        tags:         ['foo'],
      },
      xml: '<entry name="everything udp">
              <protocol>
                <udp>
                  <port>8888,8881,8882</port>
                  <source-port>1234,3214,5432</source-port>
                </udp>
              </protocol>
              <description>abc</description>
              <tag>
                <member>foo</member>
              </tag>
            </entry>',
    },
    {
      desc: 'a TCP example with destinations and source ports specified',
      attrs: {
        name:         'everything tcp',
        ensure:       'present',
        description:  'abc',
        protocol:     'tcp',
        dest_port:    '8888,8881,8882',
        src_port:     '1234,3214,5432',
        tags:         ['foo'],
      },
      xml: '<entry name="everything tcp">
              <protocol>
                <tcp>
                  <port>8888,8881,8882</port>
                  <source-port>1234,3214,5432</source-port>
                </tcp>
              </protocol>
              <description>abc</description>
              <tag>
                <member>foo</member>
              </tag>
            </entry>',
    },
    {
      desc: 'a TCP example with only a destintaion port specified',
      attrs: {
        name:         'dest_port_only',
        ensure:       'present',
        description:  'abc',
        protocol:     'tcp',
        dest_port:    '21',
        tags:         ['foo', 'bar'],
      },
      xml: '<entry name="dest_port_only">
              <protocol>
                <tcp>
                  <port>21</port>
                </tcp>
              </protocol>
              <description>abc</description>
              <tag>
                <member>foo</member>
                <member>bar</member>
              </tag>
            </entry>',
    },
    {
      desc: 'a TCP example with only a source port specified',
      attrs: {
        name:         'src_port_only',
        ensure:       'present',
        description:  'abc',
        protocol:     'tcp',
        src_port:     '21',
        tags:         ['foo', 'bar'],
      },
      xml: '<entry name="src_port_only">
              <protocol>
                <tcp>
                  <source-port>21</source-port>
                </tcp>
              </protocol>
              <description>abc</description>
              <tag>
                <member>foo</member>
                <member>bar</member>
              </tag>
            </entry>',
    },
    {
      desc: 'a TCP example without tags',
      attrs: {
        name:         'no_tags',
        ensure:       'present',
        description:  'abc',
        protocol:     'tcp',
        src_port:     '21',
      },
      xml: '<entry name="no_tags">
              <protocol>
                <tcp>
                  <source-port>21</source-port>
                </tcp>
              </protocol>
              <description>abc</description>
            </entry>',
    },
  ]

  include_examples 'xml_from_should(name, should)', test_data, described_class.new
end
