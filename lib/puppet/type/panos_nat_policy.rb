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
      type:       'String',
      desc:       'The display-name of the zone.',
      xpath:      'string(@name)',
      behaviour:  :namevar,
    },
    ensure: {
      type:       'Enum[present, absent]',
      desc:       'Whether this resource should be present or absent on the target system.',
      default:    'present',
    },
    description: {
      type:       'Optional[String]',
      desc:       'A description of the NAT Policy Rule',
      xpath:      'description/text()',
    },
    nat_type: {
      type:       'Enum["ipv4", "nat64", "nptv6"]',
      desc:       'The nat type of the policy',
      xpath:      'nat-type/text()',
      default:    'ipv4',
    },
    source_zones: {
      type:        'Optional[Array[String]]',
      desc:        'The source zone.',
      xpath_array: 'from/member/text()',
    },
    destination_zones: {
      type:        'Optional[Array[String]]',
      desc:        'One or more destination zones for the source packet.',
      xpath_array: 'to/member/text()',
    },
    destination_interface: {
      type:       'Optional[String]',
      desc:       'The destination interface for which the firewall transates.',
      xpath:      'to-interface/text()',
    },
    service: {
      type:       'Optional[String]',
      desc:       'The service the firewall is translating for.',
      xpath:      'service/text()',
    },
    source_address: {
      type:        'Optional[Array[String]]',
      desc:        'The source address of the translated packets.',
      xpath_array: 'source/member/text()',
    },
    destination_address: {
      type:        'Optional[Array[String]]',
      desc:        'The destination of the translated packet.',
      xpath_array: 'destination/member/text()',
    },
    source_translation_type: {
      type:       'Optional[Enum["dynamic-ip", "static-ip", "dynamic-ip-and-port"]]',
      desc:       'The translation applied to the source IP.',
      xpath:      'local-name(source-translation/*[1])',
    },
    SAT_interface: {
      type:       'Optional[String]',
      desc:       'The interface used in SAT',
      xpath:      'source-translation/*/interface-address/interface/text()',
    },
    SAT_interface_ip: {
      type:       'Optional[String]',
      desc:       'The interface used in SAT',
      xpath:      'source-translation/*/interface-address/ip/text()',
    },
    source_translated_address: {
      type:        'Optional[Array[String]]',
      desc:        'The translated source addresses.',
      xpath_array: 'source-translation/*/translated-address/member/text()',
    },
    source_translated_static_address: {
      type:        'Optional[String]',
      desc:        'The translated source addresses.',
      xpath:       'source-translation/static-ip/translated-address/text()',
    },
    fallback_address_type: {
      type:        'Optional[Enum["translated-address", "interface-address"]]',
      desc:        'Whether the NAT policy used translated-address or interface-address as a fallback',
      xpath:       'local-name(source-translation/*/fallback/*[1])',
    },
    fallback_address: {
      type:        'Optional[Array[String]]',
      desc:        'The translated addresses used as a fallback.',
      xpath_array: 'source-translation/*/fallback/translated-address/member/text()',
    },
    fallback_interface: {
      type:       'Optional[String]',
      desc:       'The interface used as fallback',
      xpath:      'source-translation/*/fallback/interface-address/interface/text()',
    },
    fallback_interface_ip: {
      type:       'Optional[String]',
      desc:       'The ip of the interface used as fallback',
      xpath:      'source-translation/*/fallback/interface-address/ip/text()',
    },
    fallback_interface_ip_type: {
      type:       'Optional[Enum["floating-ip", "ip"]]',
      desc:       'The type of ip for the interface used as fallback',
      xpath:      'source-translation/*/fallback/interface-address/ip/text()',
    },
    bi_directional: {
      type:       'Optional[Boolean]',
      desc:       'Determines whether the static-ip supplied is bi-directional.',
      xpath:      'source-translation/static-ip/bi-directional/text()',
    },
    destination_translated_address: {
      type:       'Optional[String]',
      desc:       'The address to which the packets are translated.',
      xpath:      'destination-translation/translated-address/text()',
    },
    destination_translated_port: {
      type:       'Optional[String]',
      desc:       'The port of the translated address',
      xpath:      'destination-translation/translated-port/text()',
    },
    disable: {
      type:        'Optional[Boolean]',
      desc:        'A boolean control to disable the NAT policy.',
      xpath:       'disabled/text()',
    },
    tags: {
      type:        'Optional[Array[String]]',
      desc:        'The Palo Alto tags to apply to this NAT Policy. Do not confuse this with the `tag` metaparameter used to filter resource application.',
      xpath_array: 'tag/member/text()',
    },
  },
  autobefore: {
    panos_commit: 'commit',
  },
)
