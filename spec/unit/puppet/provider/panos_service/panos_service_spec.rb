# frozen_string_literal: true

require 'spec_helper'
require 'support/shared_examples'

module Puppet::Provider::PanosService; end
require 'puppet/provider/panos_service/panos_service'

RSpec.describe Puppet::Provider::PanosService::PanosService do
  subject(:provider) { described_class.new }

  test_data = [
    {
      desc: 'a UDP example with destination and source ports specified',
      attrs: {
        name:         'everything udp',
        ensure:       'present',
        description:  'abc',
        protocol:     'udp',
        port:         '8888,8881,8882',
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
        port:         '8888,8881,8882',
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
        name:         'port_only',
        ensure:       'present',
        description:  'abc',
        protocol:     'tcp',
        port:         '21',
        tags:         ['foo', 'bar'],
      },
      xml: '<entry name="port_only">
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
      desc: 'a TCP example without tags',
      attrs: {
        name:         'no_tags',
        ensure:       'present',
        description:  'abc',
        protocol:     'tcp',
        port:         '21',
      },
      xml: '<entry name="no_tags">
              <protocol>
                <tcp>
                  <port>21</port>
                </tcp>
              </protocol>
              <description>abc</description>
            </entry>',
    },
  ]

  include_examples 'xml_from_should(name, should)', test_data, described_class.new
end
