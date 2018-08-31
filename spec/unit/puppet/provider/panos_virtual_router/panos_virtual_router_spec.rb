require 'spec_helper'
require 'support/shared_examples'

module Puppet::Provider::PanosVirtualRouter; end
require 'puppet/provider/panos_virtual_router/panos_virtual_router'

RSpec.describe Puppet::Provider::PanosVirtualRouter::PanosVirtualRouter do
  subject(:provider) { described_class.new }

  test_data = [
    {
      desc: 'A full virtual router example.',
      attrs: {
        name: 'Test router 1',
        interfaces: ['vlan.1', 'vlan.2', 'vlan.3'],
        ad_static: '20',
        ad_static_ipv6: '20',
        ad_ospf_int: '20',
        ad_ospf_ext: '20',
        ad_ospfv3_int: '20',
        ad_ospfv3_ext: '20',
        ad_ibgp: '20',
        ad_ebgp: '20',
        ad_rip: '20',
      },
      xml: '<entry name="Test router 1">
              <interface>
                <member>vlan.1</member>
                <member>vlan.2</member>
                <member>vlan.3</member>
              </interface>
              <admin-dists>
                <static>20</static>
                <static-ipv6>20</static-ipv6>
                <ospf-int>20</ospf-int>
                <ospf-ext>20</ospf-ext>
                <ospfv3-int>20</ospfv3-int>
                <ospfv3-ext>20</ospfv3-ext>
                <ibgp>20</ibgp>
                <ebgp>20</ebgp>
                <rip>20</rip>
              </admin-dists>
            </entry>',
    },
    {
      desc: 'A virtual router with interfaces.',
      attrs: {
        name: 'Test router 2',
        interfaces: ['vlan.1', 'vlan.2', 'vlan.3'],
      },
      xml: '<entry name="Test router 2">
              <interface>
                <member>vlan.1</member>
                <member>vlan.2</member>
                <member>vlan.3</member>
              </interface>
            </entry>',
    },
    {
      desc: 'A router with no interfaces.',
      attrs: {
        name: 'Test router 3',
        ad_static: '20',
        ad_static_ipv6: '20',
        ad_ospf_int: '20',
        ad_ospf_ext: '20',
        ad_ospfv3_int: '20',
        ad_ospfv3_ext: '20',
        ad_ibgp: '20',
        ad_ebgp: '20',
        ad_rip: '20',
      },
      xml: '<entry name="Test router 3">
              <admin-dists>
                <static>20</static>
                <static-ipv6>20</static-ipv6>
                <ospf-int>20</ospf-int>
                <ospf-ext>20</ospf-ext>
                <ospfv3-int>20</ospfv3-int>
                <ospfv3-ext>20</ospfv3-ext>
                <ibgp>20</ibgp>
                <ebgp>20</ebgp>
                <rip>20</rip>
              </admin-dists>
            </entry>',
    },
    {
      desc: 'A router with no attributes.',
      attrs: {
        name: 'Test router 4',
      },
      xml: '<entry name="Test router 4">
            </entry>',
    },
  ]

  include_examples 'xml_from_should(name, should)', test_data, described_class.new
end
