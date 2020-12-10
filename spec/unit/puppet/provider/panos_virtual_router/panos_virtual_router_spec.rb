# frozen_string_literal: true

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
  ]

  include_examples 'xml_from_should(name, should)', test_data, described_class.new

  test_data_for_munge = [
    {
      desc: 'ad_static is nil.',
      entry:  {
        name:      'ad_static',
        ad_static: nil,
      },
      munged_entry:  {
        name:           'ad_static',
        ad_static:      '10',
        ad_ebgp:        '20',
        ad_ibgp:        '200',
        ad_ospf_ext:    '110',
        ad_ospf_int:    '30',
        ad_ospfv3_ext:  '110',
        ad_ospfv3_int:  '30',
        ad_rip:         '120',
        ad_static_ipv6: '10',
      },
    },
    {
      desc: 'ad_static is not nil.',
      entry:  {
        name:      'ad_static',
        ad_static: '20',
      },
      munged_entry:  {
        name:           'ad_static',
        ad_static:      '20',
        ad_ebgp:        '20',
        ad_ibgp:        '200',
        ad_ospf_ext:    '110',
        ad_ospf_int:    '30',
        ad_ospfv3_ext:  '110',
        ad_ospfv3_int:  '30',
        ad_rip:         '120',
        ad_static_ipv6: '10',
      },
    },
    {
      desc: 'ad_static_ipv6 is nil.',
      entry:  {
        name:           'ad_static_ipv6',
        ad_static_ipv6: nil,
      },
      munged_entry:  {
        name:           'ad_static_ipv6',
        ad_static:      '10',
        ad_ebgp:        '20',
        ad_ibgp:        '200',
        ad_ospf_ext:    '110',
        ad_ospf_int:    '30',
        ad_ospfv3_ext:  '110',
        ad_ospfv3_int:  '30',
        ad_rip:         '120',
        ad_static_ipv6: '10',
      },
    },
    {
      desc: 'ad_static_ipv6 is not nil.',
      entry:  {
        name:           'ad_static_ipv6',
        ad_static_ipv6: '20',
      },
      munged_entry:  {
        name:           'ad_static_ipv6',
        ad_static_ipv6: '20',
        ad_static:      '10',
        ad_ebgp:        '20',
        ad_ibgp:        '200',
        ad_ospf_ext:    '110',
        ad_ospf_int:    '30',
        ad_ospfv3_ext:  '110',
        ad_ospfv3_int:  '30',
        ad_rip:         '120',
      },
    },
    {
      desc: 'ad_ospf_int is nil.',
      entry:  {
        name:        'ad_ospf_int',
        ad_ospf_int: nil,
      },
      munged_entry:  {
        name:           'ad_ospf_int',
        ad_static:      '10',
        ad_ebgp:        '20',
        ad_ibgp:        '200',
        ad_ospf_ext:    '110',
        ad_ospf_int:    '30',
        ad_ospfv3_ext:  '110',
        ad_ospfv3_int:  '30',
        ad_rip:         '120',
        ad_static_ipv6: '10',
      },
    },
    {
      desc: 'ad_ospf_int is not nil.',
      entry:  {
        name:        'ad_ospf_int',
        ad_ospf_int: '20',
      },
      munged_entry:  {
        name:           'ad_ospf_int',
        ad_ospf_int:    '20',
        ad_static:      '10',
        ad_ebgp:        '20',
        ad_ibgp:        '200',
        ad_ospf_ext:    '110',
        ad_ospfv3_ext:  '110',
        ad_ospfv3_int:  '30',
        ad_rip:         '120',
        ad_static_ipv6: '10',
      },
    },
    {
      desc: 'ad_ospf_ext is nil.',
      entry:  {
        name:        'ad_ospf_ext',
        ad_ospf_ext: nil,
      },
      munged_entry:  {
        name:           'ad_ospf_ext',
        ad_static:      '10',
        ad_ebgp:        '20',
        ad_ibgp:        '200',
        ad_ospf_ext:    '110',
        ad_ospf_int:    '30',
        ad_ospfv3_ext:  '110',
        ad_ospfv3_int:  '30',
        ad_rip:         '120',
        ad_static_ipv6: '10',
      },
    },
    {
      desc: 'ad_ospf_ext is not nil.',
      entry:  {
        name:        'ad_ospf_ext',
        ad_ospf_ext: '20',
      },
      munged_entry:  {
        name:           'ad_ospf_ext',
        ad_ospf_ext:    '20',
        ad_static:      '10',
        ad_ebgp:        '20',
        ad_ibgp:        '200',
        ad_ospf_int:    '30',
        ad_ospfv3_ext:  '110',
        ad_ospfv3_int:  '30',
        ad_rip:         '120',
        ad_static_ipv6: '10',
      },
    },
    {
      desc: 'ad_ospfv3_int is nil.',
      entry:  {
        name:           'ad_ospfv3_int',
        ad_ospfv3_int:  nil,
      },
      munged_entry:  {
        name:           'ad_ospfv3_int',
        ad_static:      '10',
        ad_ebgp:        '20',
        ad_ibgp:        '200',
        ad_ospf_ext:    '110',
        ad_ospf_int:    '30',
        ad_ospfv3_ext:  '110',
        ad_ospfv3_int:  '30',
        ad_rip:         '120',
        ad_static_ipv6: '10',
      },
    },
    {
      desc: 'ad_ospfv3_int is not nil.',
      entry:  {
        name:           'ad_ospfv3_int',
        ad_ospfv3_int:  '20',
      },
      munged_entry:  {
        name:           'ad_ospfv3_int',
        ad_ospfv3_int:  '20',
        ad_static:      '10',
        ad_ebgp:        '20',
        ad_ibgp:        '200',
        ad_ospf_ext:    '110',
        ad_ospf_int:    '30',
        ad_ospfv3_ext:  '110',
        ad_rip:         '120',
        ad_static_ipv6: '10',
      },
    },
    {
      desc: 'ad_ospfv3_ext is nil.',
      entry:  {
        name:           'ad_ospfv3_ext',
        ad_ospfv3_ext:  nil,
      },
      munged_entry:  {
        name:           'ad_ospfv3_ext',
        ad_static:      '10',
        ad_ebgp:        '20',
        ad_ibgp:        '200',
        ad_ospf_ext:    '110',
        ad_ospf_int:    '30',
        ad_ospfv3_ext:  '110',
        ad_ospfv3_int:  '30',
        ad_rip:         '120',
        ad_static_ipv6: '10',
      },
    },
    {
      desc: 'ad_ospfv3_ext is not nil.',
      entry:  {
        name:           'ad_ospfv3_ext',
        ad_ospfv3_ext:  '100',
      },
      munged_entry:  {
        name:           'ad_ospfv3_ext',
        ad_ospfv3_ext:  '100',
        ad_static:      '10',
        ad_ebgp:        '20',
        ad_ibgp:        '200',
        ad_ospf_ext:    '110',
        ad_ospf_int:    '30',
        ad_ospfv3_int:  '30',
        ad_rip:         '120',
        ad_static_ipv6: '10',
      },
    },
    {
      desc: 'ad_ibgp is nil.',
      entry:  {
        name:     'ad_ibgp',
        ad_ibgp:  nil,
      },
      munged_entry:  {
        name:           'ad_ibgp',
        ad_static:      '10',
        ad_ebgp:        '20',
        ad_ibgp:        '200',
        ad_ospf_ext:    '110',
        ad_ospf_int:    '30',
        ad_ospfv3_ext:  '110',
        ad_ospfv3_int:  '30',
        ad_rip:         '120',
        ad_static_ipv6: '10',
      },
    },
    {
      desc: 'ad_ibgp is not nil.',
      entry:  {
        name:     'ad_ibgp',
        ad_ibgp:  '100',
      },
      munged_entry:  {
        name:           'ad_ibgp',
        ad_ibgp:        '100',
        ad_static:      '10',
        ad_ebgp:        '20',
        ad_ospf_ext:    '110',
        ad_ospf_int:    '30',
        ad_ospfv3_ext:  '110',
        ad_ospfv3_int:  '30',
        ad_rip:         '120',
        ad_static_ipv6: '10',
      },
    },
    {
      desc: 'ad_ebgp is nil.',
      entry:  {
        name:     'ad_ebgp',
        ad_ebgp:  nil,
      },
      munged_entry:  {
        name:           'ad_ebgp',
        ad_static:      '10',
        ad_ebgp:        '20',
        ad_ibgp:        '200',
        ad_ospf_ext:    '110',
        ad_ospf_int:    '30',
        ad_ospfv3_ext:  '110',
        ad_ospfv3_int:  '30',
        ad_rip:         '120',
        ad_static_ipv6: '10',
      },
    },
    {
      desc: 'ad_ebgp is not nil.',
      entry:  {
        name:     'ad_ebgp',
        ad_ebgp:  '100',
      },
      munged_entry:  {
        name:           'ad_ebgp',
        ad_ebgp:        '100',
        ad_static:      '10',
        ad_ibgp:        '200',
        ad_ospf_ext:    '110',
        ad_ospf_int:    '30',
        ad_ospfv3_ext:  '110',
        ad_ospfv3_int:  '30',
        ad_rip:         '120',
        ad_static_ipv6: '10',
      },
    },
    {
      desc: 'ad_rip is nil.',
      entry:  {
        name:    'ad_rip',
        ad_rip:  nil,
      },
      munged_entry:  {
        name:           'ad_rip',
        ad_rip:         '120',
        ad_static:      '10',
        ad_ebgp:        '20',
        ad_ibgp:        '200',
        ad_ospf_ext:    '110',
        ad_ospf_int:    '30',
        ad_ospfv3_ext:  '110',
        ad_ospfv3_int:  '30',
        ad_static_ipv6: '10',
      },
    },
    {
      desc: 'ad_rip is not nil.',
      entry:  {
        name:    'ad_rip',
        ad_rip:  '100',
      },
      munged_entry:  {
        name:           'ad_rip',
        ad_rip:         '100',
        ad_static:      '10',
        ad_ebgp:        '20',
        ad_ibgp:        '200',
        ad_ospf_ext:    '110',
        ad_ospf_int:    '30',
        ad_ospfv3_ext:  '110',
        ad_ospfv3_int:  '30',
        ad_static_ipv6: '10',
      },
    },
  ]

  include_examples 'munge(entry)', test_data_for_munge, described_class.new
end
