require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'panos_tag',
  docs: <<-EOS,
      This type provides Puppet with the capabilities to manage "tags" objects on Palo Alto devices.
    EOS
  base_xpath: '/config/devices/entry/vsys/entry/tag',
  features: ['remote_resource'],
  attributes:   {
    name:         {
      type:       'String',
      desc:       'The display-name of the tag.',
      xpath:      'string(@name)',
      behaviour:  :namevar,
    },
    ensure:        {
      type:       'Enum[present, absent]',
      desc:       'Whether this resource should be present or absent on the target system.',
      default:    'present',
    },
    color:        {
      type:       'Optional[String]',
      desc:       'The color of the tag',
      xpath:      'color/text()',
    },
    comments:  {
      type:      'Optional[String]',
      desc:      'Provide a comment for this tag.',
      xpath:     'comments/text()',
    },
  },
  autobefore: {
    panos_commit: 'commit',
  },
)
