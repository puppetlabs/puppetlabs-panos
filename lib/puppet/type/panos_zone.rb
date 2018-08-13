require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'panos_zone',
  docs: <<-EOS,
      This type provides Puppet with the capabilities to manage "zone" objects on Palo Alto devices.
    EOS
  base_xpath: '/config/devices/entry/vsys/entry/zone',
  features: ['remote_resource'],
  attributes: {
    name: {
      type:            'String',
      desc:            'The display-name of the zone.',
      xpath:           'string(@name)',
      behaviour:       :namevar,
    },
    ensure: {
      type:            'Enum[present, absent]',
      desc:            'Whether this resource should be present or absent on the target system.',
      default:         'present',
    },
    network: {
      type:            'Optional[Enum["tap","virtual-wire","layer2","layer3"]]',
      desc:            'The network type of this zone.',
      xpath:           'local-name(network/*)',
    },
    interfaces: {
      type:            'Optional[Array[String]]',
      desc:            'The interfaces used by this zone.',
      xpath_array:     'network//member/text()',
    },
    zone_protection_profile: {
      type:            'Optional[String]',
      desc:            'The protection profile of the zone.',
      xpath:           'network/zone-protection-profile/text()',
    },
    log_setting: {
      type:            'Optional[String]',
      desc:            'The log setting of the zone.',
      xpath:           'network/log-setting/text()',
    },
    enable_user_identification: {
      type:            'Optional[Boolean]',
      desc:            'A yes/no value used to specify if the zone has enabled user identification.',
      xpath:           'enable-user-identification/text()',
    },
    nsx_service_profile: {
      type:            'Optional[Boolean]',
      desc:            'A yes/no value used to specify if the zone has a nsx service profile.',
      xpath:           'nsx-service-profile/text()',
    },
    include_list: {
      type:            'Optional[Array[String]]',
      desc:            'Array of included IP addresses or address groups.',
      xpath_array:     'user-acl/include-list/member/text()',
    },
    exclude_list: {
      type:            'Optional[Array[String]]',
      desc:            'Array of excluded IP addresses or address groups.',
      xpath_array:     'user-acl/exclude-list/member/text()',
    },
  },
  autobefore: {
    panos_commit: 'commit',
  },
)
