require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'panos_address',
  docs: <<-EOS,
      This type provides Puppet with the capabilities to manage "address" objects on Palo Alto devices.
    EOS
  base_xpath: '/config/devices/entry/vsys/entry/address',
  features: ['remote_resource'],
  attributes: {
    name: {
      type:      'Pattern[/^[a-zA-z0-9\-_\s\.]*$/]',
      desc:      'The display-name of the address.',
      behaviour: :namevar,
      xpath:      'string(@name)',
    },
    ensure: {
      type:    'Enum[present, absent]',
      desc:    'Whether this resource should be present or absent on the target system.',
      default: 'present',
    },
    description: {
      type:      'Optional[String]',
      desc:      'Provide a description of this address.',
      xpath:     'description/text()',
    },
    ip_netmask: {
      type:      'Optional[String]',
      desc:      <<DESC,
        Provide an IP address or a network using the slash notation (Ex. 192.168.80.150 or 192.168.80.0/24).
        You can also provide an IPv6 address or an IPv6 address with its prefix (Ex. 2001:db8:123:1::1 or 2001:db8:123:1::/64).
        You need to provide exactly one of ip_netmask, ip_range, or fqdn.
DESC
      xpath:     'ip-netmask/text()',
    },
    ip_range: {
      type:      'Optional[String]',
      desc:      <<DESC,
        Provide an IP address range (Ex. 10.0.0.1-10.0.0.4).
        Each of the IP addresses in the range can also be in an IPv6 form (Ex. 2001:db8:123:1::1-2001:db8:123:1::11).
        You need to provide exactly one of ip_netmask, ip_range, or fqdn.
DESC
      xpath:     'ip-range/text()',
    },
    fqdn: {
      type:      'Optional[String]',
      desc:      'Provide a fully qualified domain name. You need to provide exactly one of ip_netmask, ip_range, or fqdn.',
      xpath:     'fqdn/text()',
    },
    tags: {
      type:      'Array[String]',
      desc:      'The Palo Alto tags to apply to this address. Do not confuse this with the `tag` metaparameter used to filter resource application.',
      default:   [],
      xpath_array:     'tag/member/text()',
    },
  },
  autobefore: {
    panos_commit: 'commit',
  },
)
