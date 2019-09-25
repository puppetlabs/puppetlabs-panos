require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'panos_application_group',
  docs: <<-EOS,
This type provides Puppet with the capabilities to manage "application_groups" objects on Palo Alto devices.
EOS
  base_xpath: '/config/devices/entry/vsys/entry/application-group',
  features: ['remote_resource'],
  attributes: {
    name: {
      type:      'Pattern[/^[a-zA-z0-9\-_\s\.]{1,63}$/]',
      desc:      'The display-name of the address-group.',
      behaviour: :namevar,
      xpath:      'string(@name)',
    },
    ensure: {
      type:    'Enum[present, absent]',
      desc:    'Whether this resource should be present or absent on the target system.',
      default: 'present',
    },
    members: {
      type:         'Optional[Array[String]]',
      desc:         'One or more `panos_application` or `panos_application_group` or `panos_application_filter` that form this group.',
      xpath_array:  'members/member/text()',
    },
  },
  autobefore: {
    panos_commit: 'commit',
  },
)
