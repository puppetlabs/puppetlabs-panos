# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'panos_virtual_router',
  docs: <<-EOS,
This type provides Puppet with the capabilities to manage "virtual router" objects on Palo Alto devices.
EOS
  base_xpath: '/config/devices/entry/network/virtual-router',
  features: ['remote_resource'],
  attributes: {
    name: {
      type:       'Pattern[/^[a-zA-z0-9\-_\s\.]{1,31}$/]',
      desc:       'The display-name of the tag.',
      xpath:      'string(@name)',
      behaviour:  :namevar,
    },
    ensure: {
      type:       'Enum[present, absent]',
      desc:       'Whether this resource should be present or absent on the target system.',
      default:    'present',
    },
    interfaces: {
      type:        'Optional[Array[String]]',
      desc:        'The color of the tag',
      xpath_array: 'interface/member/text()',
    },
    ad_static: {
      type:      'String',
      desc:      'Static IPv4 Administrative distance. Range is 10-240.',
      xpath:     'admin-dists/static/text()',
      default:   '10',
    },
    ad_static_ipv6: {
      type:      'String',
      desc:      'Static IPv6 Administrative distance. Range is 10-240.',
      xpath:     'admin-dists/static-ipv6/text()',
      default:   '10',
    },
    ad_ospf_int: {
      type:      'String',
      desc:      'OSPF Interface Administrative distance. Range is 10-240.',
      xpath:     'admin-dists/ospf-int/text()',
      default:   '30',
    },
    ad_ospf_ext: {
      type:      'String',
      desc:      'OSPF External Administrative distance. Range is 10-240.',
      xpath:     'admin-dists/ospf-ext/text()',
      default:   '110',
    },
    ad_ospfv3_int: {
      type:      'String',
      desc:      'OSPFv3 External Administrative distance. Range is 10-240.',
      xpath:     'admin-dists/ospfv3-int/text()',
      default:   '30',
    },
    ad_ospfv3_ext: {
      type:      'String',
      desc:      'OSPFv3 Interface Administrative distance. Range is 10-240.',
      xpath:     'admin-dists/ospfv3-ext/text()',
      default:   '110',
    },
    ad_ibgp: {
      type:      'String',
      desc:      'IBGP Administrative distance. Range is 10-240.',
      xpath:     'admin-dists/ibgp/text()',
      default:   '200',
    },
    ad_ebgp: {
      type:      'String',
      desc:      'EBGP administrative distance. Range is 10-240.',
      xpath:     'admin-dists/ebgp/text()',
      default:   '20',
    },
    ad_rip: {
      type:      'String',
      desc:      'RIP administrative distance. Range is 10-240.',
      xpath:     'admin-dists/rip/text()',
      default:   '120',
    },
  },
  autobefore: {
    panos_commit: 'commit',
  },
)
