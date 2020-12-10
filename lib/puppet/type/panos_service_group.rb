# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'panos_service_group',
  docs: <<-EOS,
This type provides Puppet with the capabilities to manage "Service Group" objects on Palo Alto devices.
EOS
  base_xpath: '/config/devices/entry/vsys/entry/service-group',
  features: ['remote_resource'],
  attributes: {
    name: {
      type:      'Pattern[/^[a-zA-z0-9\-_\s\.]{1,63}$/]',
      desc:      'The display-name of the service-group.',
      behaviour: :namevar,
      xpath:      'string(@name)',
    },
    ensure: {
      type:    'Enum[present, absent]',
      desc:    'Whether this resource should be present or absent on the target system.',
      default: 'present',
    },
    services: {
      type:         'Array[String]',
      desc:         'An array of `panos_service`, or `panos_service_group` that form this group.',
      xpath_array:  'members/member/text()',
    },
    tags: {
      type:         'Array[String]',
      desc:         'The Palo Alto tags to apply to this service-group. Do not confuse this with the `tag` metaparameter used to filter resource application.',
      default:      [],
      xpath_array:  'tag/member/text()',
    },
  },
  autobefore: {
    panos_commit: 'commit',
  },
)
