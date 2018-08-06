require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'panos_address_group',
  docs: <<-EOS,
      This type provides Puppet with the capabilities to manage "address_groups" objects on Palo Alto devices.
    EOS
  base_xpath: '/config/devices/entry/vsys/entry/address-group',
  features: ['remote_resource'],
  attributes: {
    name: {
      type:      'Pattern[/^[a-zA-z0-9\-_\s\.]*$/]',
      desc:      'The display-name of the address-group.',
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
      desc:      'Provide a description of this address-group.',
      xpath:     'description/text()',
    },
    type: {
      type:      'Enum["static", "dynamic"]',
      desc:      'A `static` or `dynamic` address-group.',
      xpath:     'local-name(static|dynamic)',
    },
    static_members: {
      type:      'Optional[Array[String]]',
      desc:      'An array of `panos_address`, or `panos_address_group` that form this group. Used only when type is static.',
      xpath_array:     'static/member/text()',
    },
    dynamic_filter: {
      type:      'Optional[String]',
      desc:      <<DESC,
      To create a dynamic address group, use the match criteria to assemble the members to be included in the group.
      Define the Match criteria using the AND or OR operators.
        example: 'tag1' and 'tag2' or 'tag3'
      Used only when type is dynamic.
DESC
      xpath:      'dynamic/filter/text()',
    },
    tags: {
      type:      'Array[String]',
      desc:      'The Palo Alto tags to apply to this address-group. Do not confuse this with the `tag` metaparameter used to filter resource application.',
      default:   [],
      xpath_array:     'tag/member/text()',
    },
  },
  autobefore: {
    panos_commit: 'commit',
  },
)
