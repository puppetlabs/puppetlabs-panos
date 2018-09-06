require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'panos_nat_policy',
  docs: <<-EOS,
      This type provides Puppet with the capabilities to manage "NAT Policy Rule" objects on Palo Alto devices.
    EOS
  base_xpath: '/config/devices/entry/vsys/entry/rulebase/nat/rules',
  features: ['remote_resource'],
  attributes: {
    name: {
      type:       'Pattern[/^[a-zA-z0-9\-_\s\.]{1,63}$/]',
      desc:       'The display-name of the zone. Restricted to 31 characters on PAN-OS version 7.1.0.',
      xpath:      'string(@name)',
      behaviour:  :namevar,
    },
    ensure: {
      type:    'Enum[present, absent]',
      desc:    'Whether this resource should be present or absent on the target system.',
      default: 'present',
    },
    description: {
      type:  'Optional[String]',
      desc:  'A description of the NAT Policy Rule',
      xpath: 'description/text()',
    },
    nat_type: {
      type:    'Enum["ipv4", "nat64", "nptv6"]',
      desc:    'The nat type of the policy',
      xpath:   'nat-type/text()',
      default: 'ipv4',
    },
    from: {
      type:        'Array[String]',
      desc:        <<DESC,
Specify one or more source zones for the original (non-NAT) packet. Zones must be of the same type (Layer 2, Layer 3, or virtual wire).
You can specify multiple zones to simplify management. For example, you can configure settings so that multiple internal NAT addresses are directed to the same external IP address.
DESC
      xpath_array: 'from/member/text()',
      default:     ['any'],
    },
    to: {
      type:        'Array[String]',
      desc:        <<DESC,
Specify one or more destinations zones for the original (non-NAT) packet. Zones must be of the same type (Layer 2, Layer 3, or virtual wire).
You can specify multiple zones to simplify management. For example, you can configure settings so that multiple internal NAT addresses are directed to the same external IP address.
DESC
      xpath_array: 'to/member/text()',
    },
    destination_interface: {
      type:  'Optional[String]',
      desc:  <<DESC,
Specify the destination interface of packets the firewall translates.
You can use the destination interface to translate IP addresses differently in the case where the network is connected to two ISPs with different IP address pools
DESC
      xpath: 'to-interface/text()',
    },
    service: {
      type:    'String',
      desc:    'Specify the service for which the firewall translates the source or destination address.',
      xpath:   'service/text()',
      default: 'any',
    },
    source: {
      type:        'Array[String]',
      desc:        <<DESC,
Specify a combination of source addresses for the firewall to translate.
For NPTv6, the prefixes configured for Source Address and Destination Address must be in the format xxxx:xxxx::/yy.
The address cannot have an interface identifier (host) portion defined. The range of supported prefix lengths is /32 to /64.
DESC
      xpath_array: 'source/member/text()',
      default:     ['any'],
    },
    destination: {
      type:        'Array[String]',
      desc:        <<DESC,
Specify a combination of destination addresses for the firewall to translate.
For NPTv6, the prefixes configured for Source Address and Destination Address must be in the format xxxx:xxxx::/yy.
The address cannot have an interface identifier (host) portion defined. The range of supported prefix lengths is /32 to /64.
DESC
      xpath_array: 'destination/member/text()',
      default:     ['any'],
    },
    source_translation_type: {
      type:  'Optional[Enum["dynamic-ip", "static-ip", "dynamic-ip-and-port", "none"]]',
      desc:  <<DESC,
The size of the address range is limited by the type of address pool:

* dynamic-ip-and-port: Address selection is based on a hash of the source IP address.
  For a given source IP address, the firewall will use the same translated source address for all sessions.
  Dynamic IP and Port source NAT supports approximately 64k concurrent sessions on each IP address in the NAT pool.
  On some platforms, over-subscription is supported, which will allow a single IP to host more than 64k concurrent sessions.
  Palo Alto Networks Dynamic IP/port NAT supports more NAT sessions than are supported by the number of available IP addresses and ports.
  The firewall can use IP address and port combinations up to two times (simultaneously) on the PA-200, PA-500, PA-2000 Series and PA-3000 Series firewalls,
  four times on the PA-4020 and PA-5020 firewalls, and eight times on the PA‑4050, PA-4060, PA-5050, and PA-5060 firewalls when destination IP addresses are unique.

* dynamic-ip: The next available address in the specified range is used, but the port number is unchanged. Up to 32k consecutive IP addresses are supported.
  A dynamic IP pool can contain multiple subnets, so you can translate your internal network addresses to two or more separate public subnets.
    * Advanced (Fall back Dynamic IP Translation)—Use this option to create a fall back pool that will perform IP and port translation and will be used if the primary pool runs out of addresses.
      You can define addresses for the pool by using the Translated Address option or the Interface Address option, which is for interfaces that receive an IP address dynamically.
      When creating a fall back pool, make sure addresses do not overlap with addresses in the primary pool.

* static-ip: The same address is always used for the translation and the port is unchanged.
  For example, if the source range is 192.168.0.1-192.168.0.10 and the translation range is 10.0.0.1-10.0.0.10, address 192.168.0.2 is always translated to 10.0.0.2. The address range is virtually unlimited.
    * NPTv6 must use Static IP translation for Source Address Translation. For NPTv6, the prefixes configured for Translated Address must be in the format xxxx:xxxx::/yy.
      The address cannot have an interface identifier (host) portion defined. The range of supported prefix lengths is /32 to /64.

* None: Translation is not performed.
DESC
      xpath: 'local-name(source-translation/*[1])',
    },
    SAT_interface: {
      type:  'Optional[String]',
      desc:  'The interface used in SAT',
      xpath: 'source-translation/*/interface-address/interface/text()',
    },
    SAT_interface_ip: {
      type:  'Optional[String]',
      desc:  'The interface used in SAT',
      xpath: 'source-translation/*/interface-address/ip/text()',
    },
    source_translated_address: {
      type:        'Optional[Array[String]]',
      desc:        'The translated source addresses.',
      xpath_array: 'source-translation/*/translated-address/member/text()',
    },
    source_translated_static_address: {
      type:  'Optional[String]',
      desc:  'The translated source addresses.',
      xpath: 'source-translation/static-ip/translated-address/text()',
    },
    fallback_address_type: {
      type:  'Optional[Enum["translated-address", "interface-address"]]',
      desc:  'Whether the NAT policy used translated-address or interface-address as a fallback',
      xpath: 'local-name(source-translation/*/fallback/*[1])',
    },
    fallback_address: {
      type:        'Optional[Array[String]]',
      desc:        'The translated addresses used as a fallback. Required if `fallback_address_type` is set to `translated-address`',
      xpath_array: 'source-translation/*/fallback/translated-address/member/text()',
    },
    fallback_interface: {
      type:  'Optional[String]',
      desc:  'The interface used as fallback. Required if `fallback_address_type` is set to `interface-address`',
      xpath: 'source-translation/*/fallback/interface-address/interface/text()',
    },
    fallback_interface_ip: {
      type:  'Optional[String]',
      desc:  'The ip of the interface used as fallback. Required if `fallback_address_type` is set to `interface-address`',
      xpath: 'source-translation/*/fallback/interface-address/ip/text()',
    },
    fallback_interface_ip_type: {
      type:  'Optional[Enum["floating-ip", "ip"]]',
      desc:  'The type of ip for the interface used as fallback. Required if `fallback_address_type` is set to `interface-address`',
      xpath: 'source-translation/*/fallback/interface-address/ip/text()',
    },
    bi_directional: {
      type:  'Optional[Boolean]',
      desc:  <<DESC,
Enable bidirectional translation if you want the firewall to create a corresponding translation (NAT or NPTv6) in the opposite direction of the translation you configure.
Note: If you enable bidirectional translation, you must ensure that you have security policies in place to control the traffic in both directions. Without such policies,
the bidirectional feature allows packets to be translated automatically in both directions.
DESC
      xpath: 'source-translation/static-ip/bi-directional/text()',
    },
    destination_translated_address: {
      type:  'Optional[String]',
      desc:  <<DESC,
The address to which the packets are translated.

For NPTv6, the prefixes configured for Destination prefix Translated Address must be in the format xxxx:xxxx::/yy.
The address cannot have an interface identifier (host) portion defined. The range of supported prefix lengths is /32 to /64.
      DESC
      xpath: 'destination-translation/translated-address/text()',
    },
    destination_translated_port: {
      type:  'Optional[String]',
      desc:  <<DESC,
The port of the translated address

Note that Translated Port is not supported for NPTv6 because NPTv6 is strictly prefix translation. The Port and Host address section is simply forwarded unchanged.
DESC
      xpath: 'destination-translation/translated-port/text()',
    },
    disable: {
      type:  'Optional[Boolean]',
      desc:  'A boolean control to disable the NAT policy.',
      xpath: 'disabled/text()',
    },
    tags: {
      type:        'Optional[Array[String]]',
      desc:        <<DESC,
A policy tag is a keyword or phrase that allows you to sort or filter policies.
This is useful when you have defined many policies and want to view those that are tagged with a particular keyword.
DESC
      xpath_array: 'tag/member/text()',
    },
  },
  autobefore: {
    panos_commit: 'commit',
  },
)
