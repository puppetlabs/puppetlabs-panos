# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'panos_path_monitor',
  docs: <<-EOS,
@summary This type provides Puppet with the capabilities to manage IPv4 Path Monitors on Palo Alto devices.

@note Can only be configured on PAN-OS 8.1.0 devices.
EOS
  base_xpath: '/config/devices/entry/network/virtual-router',
  features: ['remote_resource'],
  title_patterns: [
    {
      pattern: %r{^(?<route>[^/]*/[^/]*)/(?<path>.*)$},
      desc: 'Where the name and the static route are provided with a forward slash seperator',
    },
  ],
  attributes: {
    path: {
      type:       'String',
      desc:       'The name to identify the path monitor with.',
      xpath:      'string(@name)',
      behaviour:  :namevar,
    },
    route: {
      type:       'String',
      desc:       'A name to identify the static route which is usually the virtual router name followed by a forward slash.',
      behaviour:  :namevar,
    },
    ensure: {
      type:       'Enum[present, absent]',
      desc:       'Whether this resource should be present or absent on the target system.',
      default:    'present',
    },
    source: {
      type: 'String',
      desc: <<DESC,
Specify the IP address that the firewall will use as the source in the ICMP ping to the monitored destination:

  * If the interface has multiple IP addresses, select one.
  * If you specify an interface, the firewall uses the first IP address assigned to the interface by default.
  * If you specify `DHCP` (Use DHCP Client address), the firewall uses the address that DHCP assigned to the interface. To see the DHCP address, select NetworkInterfacesEthernet and in the row for the Ethernet interface, click on Dynamic DHCP Client. The IP Address appears in the Dynamic IP Interface Status window.
DESC
      xpath: 'source/text()',
    },
    destination: {
      type: 'String',
      desc: <<DESC,
Specify a robust, stable IP address or address object for which the firewall will monitor the path. The monitored destination and the static route destination must use the same address family (IPv4 or IPv6)
DESC
      xpath: 'destination/text()',
    },
    interval: {
      type:     'Optional[String]',
      desc:     <<DESC,
Specify the ICMP ping interval in seconds to determine how frequently the firewall monitors the path (pings the monitored destination; range is 1-60; default is 3).
DESC
      xpath:    'interval/text()',
      default:  '3',
    },
    count: {
      type:     'Optional[String]',
      desc:     <<DESC,
Specify the number of consecutive ICMP ping packets that do not return from the monitored destination before the firewall considers the link down. Based on the Any or All failure condition, if path monitoring is in failed state, the firewall removes the static route from the RIB (range is 3-10; default is 5).

For example, a Ping Interval of 3 seconds and Ping Count of 5 missed pings (the firewall receives no ping in the last 15 seconds) means path monitoring detects a link failure. If path monitoring is in failed state and the firewall receives a ping after 15 seconds, the link is deemed up; based on the Any or All failure condition, path monitoring to Any or All monitored destinations can be deemed up, and the Preemptive Hold Time starts.
DESC
      xpath:    'count/text()',
      default:  '5',
    },
    enable: {
      type: 'Optional[Boolean]',
      desc: <<DESC,
Select to enable path monitoring of this specific destination for the static route; the firewall sends ICMP pings to this destination.
DESC
      xpath: 'enable/text()',
    },
  },
  autobefore: {
    panos_commit: 'commit',
  },
  autorequire: {
    panos_static_route: '$route',
  },
)
