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
      type:            'Pattern[/^[a-zA-z0-9\-\s_\.]{1,31}$/]',
      desc:            'The display-name of the zone.',
      xpath:           'string(@name)',
      behaviour:       :namevar,
    },
    ensure: {
      type:    'Enum[present, absent]',
      desc:    'Whether this resource should be present or absent on the target system.',
      default: 'present',
    },
    network: {
      type:    'Enum["tap", "virtual-wire", "layer2", "layer3", "tunnel"]',
      desc:    'The network type of this zone. An interface can belong to only one zone in one virtual system. Note: `tunnel` can only be set on PAN-OS version 8.1.0.',
      xpath:   'local-name(network/*)',
      default: 'layer3',
    },
    interfaces: {
      type:        'Optional[Array[String]]',
      desc:        'One or more interfaces used by this zone.',
      xpath_array: 'network//member/text()',
    },
    zone_protection_profile: {
      type:  'Optional[String]',
      desc:  'Specify a profile that specifies how the security gateway responds to attacks from this zone',
      xpath: 'network/zone-protection-profile/text()',
    },
    log_setting: {
      type:  'Optional[String]',
      desc:  'Specify a log forwarding profile for forwarding zone protection logs to an external system',
      xpath: 'network/log-setting/text()',
    },
    enable_user_identification: {
      type:  'Optional[Boolean]',
      desc:  <<DESC,
If you configured User-ID™ to perform IP address-to-username mapping (discovery), select this option to apply the mapping information to traffic in this zone.
If you disable this option, firewall logs, reports, and policies will exclude user mapping information for traffic within the zone.

By default, if you enable this option, the firewall applies user mapping information to the traffic of all subnetworks in the zone.
To limit the information to specific subnetworks within the zone, use the `include_list` and `exclude_list`.

Note: User-ID performs discovery for the zone only if it falls within the network range that User-ID monitors.
If the zone is outside that range, the firewall does not apply user mapping information to the zone traffic even if  `enable_user_identification` is seelcted.
DESC
      xpath: 'enable-user-identification/text()',
    },
    enable_packet_buffer_protection: {
      type:  'Optional[Boolean]',
      desc:  <<DESC,
If you have configured Packet Buffer Protection on the device, enable this option to apply the packet buffer protection settings to this zone. Packet buffer protection is applied to the ingress zone only.

Note: can only be set on PAN-OS version 8.1.0.
DESC
      xpath: 'network/enable-packet-buffer-protection/text()',
    },
    nsx_service_profile: {
      type:  'Optional[Boolean]',
      desc:  'Specify if the zone should have a nsx service profile. Note: can only be set on PAN-OS version 7.1.0.',
      xpath: 'nsx-service-profile/text()',
    },
    include_list: {
      type:        'Optional[Array[String]]',
      desc:        <<DESC,
By default, if you do not specify subnetworks in this list, the firewall applies the user mapping information it discovers to all the traffic of this zone for use in logs, reports, and policies.

To limit the application of user mapping information to specific subnetworks within the zone, then for each subnetwork click Add and select an address (or address group) object or type the IP address range (for example, 10.1.1.1/24).
The exclusion of all other subnetworks is implicit: you do not need to add them to the `exclude_list`.

Add entries to the `exclude_list` only to exclude user mapping information for a subset of the subnetworks in the `include_list`. For example, if you add 10.0.0.0/8 to the Include List and add 10.2.50.0/22 to the `exclude_list`,
the firewall includes user mapping information for all the zone subnetworks of 10.0.0.0/8 except 10.2.50.0/22, and excludes information for all zone subnetworks outside of 10.0.0.0/8.
Note that you can only include subnetworks that fall within the network range that User-ID monitors.
DESC
      xpath_array: 'user-acl/include-list/member/text()',
    },
    exclude_list: {
      type:        'Optional[Array[String]]',
      desc:        <<DESC,
To exclude user mapping information for a subset of the subnetworks in the `include_list`, for each subnetwork to exclude, specify an address (or address group) or type the IP address range.

Note: If you add entries to the Exclude List but not the Include List, the firewall excludes user mapping information for all subnetworks within the zone, not just the subnetworks you added.
DESC
      xpath_array: 'user-acl/exclude-list/member/text()',
    },
  },
  autobefore: {
    panos_commit: 'commit',
  },
)
