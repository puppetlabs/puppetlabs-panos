require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'panos_service',
  docs: <<-EOS,
      This type provides Puppet with the capabilities to manage "service" objects on Palo Alto devices.
    EOS
  base_xpath: '/config/devices/entry/vsys/entry/service',
  features: ['remote_resource'],
  attributes: {
    name: {
      type:      'Pattern[/^[a-zA-z0-9\-_\s\.]{1,63}$/]',
      desc:      'The display-name of the service.',
      xpath:     'string(@name)',
      behaviour: :namevar,
    },
    ensure: {
      type:      'Enum[present, absent]',
      desc:      'Whether this resource should be present or absent on the target system.',
      default:   'present',
    },
    description: {
      type:  'Optional[String]',
      desc:  'Provide a description of this service.',
      xpath: 'description/text()',
    },
    protocol: {
      type:    'Enum["tcp", "udp"]',
      desc:    'Specify the protocol used by the service',
      xpath:   'local-name(protocol/*[1])',
      default: 'tcp',
    },
    port: {
      type:  'String',
      desc:  'Port can be a single port number, a range `1-65535`, or comma separated values  `80, 8080, 443`',
      xpath: 'protocol/*[1]/port/text()',
    },
    src_port: {
      type:  'Optional[String]',
      desc:  'Port can be a single port number, a range `1-65535`, or comma separated values  `80, 8080, 443`',
      xpath: 'protocol/*[1]/source-port/text()',
    },
    tags: {
      type:        'Array[String]',
      desc:        'The Palo Alto tags to apply to this address-group. Do not confuse this with the `tag` metaparameter used to filter resource application.',
      default:     [],
      xpath_array: 'tag/member/text()',
    },
  },
  autobefore: {
    panos_commit: 'commit',
  },
)
