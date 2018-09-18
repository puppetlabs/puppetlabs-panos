require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'panos_ipv6_static_route',
  docs: <<-EOS,
      This type provides Puppet with the capabilities to manage IPv6 Static Routes on Palo Alto devices.
    EOS
  base_xpath: '/config/devices/entry/network/virtual-router',
  features: ['remote_resource'],
  title_patterns: [
    {
      pattern: %r{^(?<vr_name>[^/]*)/(?<route>.*)$},
      desc: 'Where the name and the virtual router are provided with a forward slash seperator',
    },
  ],
  attributes: {
    route: {
      type:       'Pattern[/^[a-zA-z0-9\-_\s\.]{1,31}$/]',
      desc:       'A name to identify a static route.',
      xpath:      'string(@name)',
      behaviour:  :namevar,
    },
    vr_name: {
      type:       'String',
      desc:       'The name of the virtual router the static route is associate with.',
      behaviour:  :namevar,
    },
    ensure: {
      type:       'Enum[present, absent]',
      desc:       'Whether this resource should be present or absent on the target system.',
      default:    'present',
    },
    nexthop: {
      type:      'Optional[String]',
      desc:      'The address of the next hop location for the route',
      xpath:     'string(nexthop/*)',
    },
    nexthop_type: {
      type:      'Optional[Enum["ipv6-address", "next-vr", "discard", "none"]]',
      desc:      <<DESC,
The type of address used for the next hop.

  * ipv6-address: Select to enter the IP address of the next hop router.
  * next-vr: Select to select a virtual router in the firewall as the next hop. This allows you to route internally between virtual routers within a single firewall.
  * discard: Select if you want to drop traffic that is addressed to this destination.
  * none: Select if there is no next hop for the route.
DESC
      xpath:     'local-name(nexthop/*)',
    },
    bfd_profile: {
      type:      'String',
      desc:      <<DESC,
To enable Bidirectional Forwarding Detection (BFD) for a static route on a PA-3000 Series, PA-3200 Series, PA-5000 Series, PA-5200 Series,
PA-7000 Series, or VM-Series firewall, specify one of the following:

  * `default`: a BFD profile that you have created on the firewall
  * `None`: to disable BFD for the static route.

To use BFD on a static route:

  * Both the firewall and the peer at the opposite end of the static route must support BFD sessions.
  * The static route nexthop_type must be `ip-address` and you must enter a valid IP address in `nexthop`.
  * The `interface` attribute cannot be `none`; you must specify an interface (even if you are using a DHCP address).
DESC
      xpath:     'bfd/profile/text()',
      default:   'None',
    },
    interface: {
      type:      'Optional[String]',
      desc:      'The interface used by the route, interfaces pulled from the virtual router this belongs to.',
      xpath:     'interface/text()',
    },
    metric: {
      type:      'Optional[String]',
      desc:      'Specify a valid metric for the static route (1 - 65535).',
      xpath:     'metric/text()',
    },
    admin_distance: {
      type:      'String',
      desc:      'Specify the administrative distance for the static route (10-240; default is 10).',
      xpath:     'admin-dist/text()',
      default:   '10',
    },
    destination: {
      type:      'String',
      desc:      'Enter an IP address and network mask in Classless Inter-domain Routing (CIDR) notation: ip_address/mask (for example, 192.168.2.0/24 for IPv4 or 2001:db8::/32 for IPv6).',
      xpath:     'destination/text()',
    },
    no_install: {
      type:       'Boolean',
      desc:       <<DESC,
Select if you do not want to install the route in the forwarding table. The route is retained in the configuration for future reference. Note: can only be set on PAN-OS version 7.1.0.
DESC
      xpath:      'local-name(option/no-install)',
      default:    false,
    },
    route_type: {
      type:   'Optional[Enum["unicast", "multicast", "both", "no-install"]]',
      desc:   <<DESC,
Specify the route table into which the firewall installs the static route:

  * `unicast`: Installs the route into the unicast route table.
  * `multicast`: Installs the route into the multicast route table.
  * `both`: Installs the route into the unicast and multicast route tables.
  * `no-install`: Does not install the route in the route table (RIB); the firewall retains the static route for future reference until you delete the route.

Note: can only be set on PAN-OS version 8.1.0.
DESC
      xpath:  'local-name(route-table/*)',
    },
    path_monitoring: {
      type:    'Optional[Boolean]',
      desc:    <<DESC,
Specify true to enable path monitoring for the static route.

Note: can only be set on PAN-OS version 8.1.0.
Note: must be enabled if using `panos_ipv6_monitor_destinations` for the static route.
DESC
      xpath:   'local-name(path-monitor)',
    },
    failure_condition: {
      type:    'Optional[Enum["any", "all"]]',
      desc:    <<DESC,
Specify the condition under which the firewall considers the monitored path down and thus the static route down:

  * `any`: If any one of the monitored destinations for the static route is unreachable by ICMP, the firewall removes the static route from the RIB and FIB and adds the dynamic or static route that has the next lowest metric going to the same destination to the FIB.
  * `all`: If all of the monitored destinations for the static route are unreachable by ICMP, the firewall removes the static route from the RIB and FIB and adds the dynamic or static route that has the next lowest metric going to the same destination to the FIB.

Specify `all` to avoid the possibility of a single monitored destination signaling a static route failure when that monitored destination is simply offline for maintenance, for example.

Note: can only be set on PAN-OS version 8.1.0.
DESC
      xpath:   'path-monitor/failure-condition/text()',
    },
    enable: {
      type:    'Optional[Boolean]',
      desc:    <<DESC,
Specify true to enable path monitoring of this specific destination for the static route; the firewall sends ICMP pings to this destination.

Note: can only be set on PAN-OS version 8.1.0.
DESC
      xpath:   'path-monitor/enable/text()',
    },
    hold_time: {
      type:    'Optional[String]',
      desc:    <<DESC,
Specify the number of minutes a downed path monitor must remain in Up stat:the path monitor evaluates all of its member monitored destinations and must remain Up before the firewall reinstalls the static route into the RIB. If the timer expires without the link going down or flapping, the link is deemed stable, path monitor can remain Up, and the firewall can add the static route back into the RIB.

If the link goes down or flaps during the hold time, path monitor fails and the timer restarts when the downed monitor returns to Up state. A Preemptive Hold Time of zero causes the firewall to reinstall the static route into the RIB immediately upon the path monitor coming up. Range is 0-1,440; default is 2.

Note: can only be set on PAN-OS version 8.1.0.
DESC
      xpath:   'path-monitor/hold-time/text()',
    },
  },
  autobefore: {
    panos_commit: 'commit',
  },
  autorequire: {
    panos_virtual_router:    '$vr_name',
  },
)
