require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'panos_custom_url_category',
  docs: <<-EOS,
This type provides Puppet with the capabilities to manage "custom_url_category" objects on Palo Alto devices.
EOS
  base_xpath: '/config/devices/entry/vsys/entry/profiles/custom-url-category',
  features: ['remote_resource'],
  attributes: {
    name: {
      type:      'Pattern[/^[a-zA-z0-9\-_\s\.]{1,63}$/]',
      desc:      'The display-name of the url category.',
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
      desc:      'Provide a description of this url category.',
      xpath:     'description/text()',
    },
    category_type: {
      type:         'Optional[String]',
      desc:         'Type should be `URL List` or `Category Match`. This parameter apeared in 9.0 and is mandatory for these versions',
      xpath_array:  'type/text()',
    },
    list: {
      type:         'Optional[Array[String]]',
      desc:         'One or more urls that form this category.',
      xpath_array:  'list/member/text()',
    },
  },
  autobefore: {
    panos_commit: 'commit',
  },
)
