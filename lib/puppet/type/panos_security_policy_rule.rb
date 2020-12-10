# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'panos_security_policy_rule',
  docs: <<-EOS,
This type provides Puppet with the capilities to manage "Security Policy Rules" on Palo Alto devices.
EOS
  base_xpath: '/config/devices/entry/vsys/entry/rulebase/security/rules',
  features: ['remote_resource'],
  attributes: {
    name: {
      type:      'Pattern[/^[a-zA-z0-9\-_\s\.]{1,63}$/]',
      desc:      'The display-name of the security-policy-rule. Restricted to 31 characters on PAN-OS version 7.1.0.',
      behaviour: :namevar,
      xpath:     'string(@name)',
    },
    ensure: {
      type:    'Enum[present, absent]',
      desc:    'Whether this resource should be present or absent on the target system.',
      default: 'present',
    },
    rule_type: {
      type:    'Enum["universal", "interzone", "intrazone"]',
      desc:    <<DESC,
Specifies whether the rule applies to traffic within a zone, between zones, or both:

* universal: Applies the rule to all matching interzone and intrazone traffic in the specified source and destination zones.
For example, if you create a universal role with source zones A and B and destination zones A and B, the rule would apply to
all traffic within zone A, all traffic within zone B, and all traffic from zone A to zone B and all traffic from zone B to zone A.

* intrazone: Applies the rule to all matching traffic within the specified source zones (you cannot specify a destination zone for
intrazone rules). For example, if you set the source zone to A and B, the rule would apply to all traffic within zone A and all
traffic within zone B, but not to traffic between zones A and B.

* interzone: Applies the rule to all matching traffic between the specified source and destination zones. For example, if you set
the source zone to A, B, and C and the destination zone to A and B, the rule would apply to traffic from zone A to zone B, from zone B
to zone A, from zone C to zone A, and from zone C to zone B, but not traffic within zones A, B, or C.
DESC
      default: 'universal',
      xpath:   'rule-type/text()',
    },
    description: {
      type:  'Optional[String]',
      desc:  'Provide a description of the service.',
      xpath: 'description/text()',
    },
    tags: {
      type:        'Optional[Array[String]]',
      desc:        <<DESC,
A policy tag is a keyword or phrase that allows you to sort or filter policies. This is useful when you have defined many policies and want to
view those that are tagged with a particular keyword.For example, you may want to tag certain rules with specific words like Decrypt and No-decrypt,
or use the name of a specific data center for policies associated with that location.
DESC
      xpath_array: 'tag/member/text()',
    },
    source_zones: {
      type:        'Array[String]',
      desc:        <<DESC,
Zones must be of the same type (Layer 2, Layer 3, or virtual wire).

Multiple zones can be used to simplify management. For example, if you have three different internal zones (Marketing, Sales, and Public Relations)
that are all directed to the untrusted destination zone, you can create one rule that covers all cases.
DESC
      default:     ['any'],
      xpath_array: 'from/member/text()',
    },
    source_address:  {
      type:        'Array[String]',
      desc:        'The list of source addresses, address groups, or regions',
      default:     ['any'],
      xpath_array: 'source/member/text()',
    },
    negate_source:  {
      type:  'Optional[Boolean]',
      desc:  'Matches on the reverse of the `source_address` value.',
      xpath: 'negate-source/text()',
    },
    source_users:  {
      type:        'Array[String]',
      desc:        <<DESC,
The following source values are supported:

* ['any']: Include any traffic regardless of user data.

* ['pre-logon']: Include remote users that are connected to the network using GlobalProtect, but are not logged into their system.
When the Pre-logon option is configured on the Portal for GlobalProtect clients, any user who is not currently logged into their machine
will be identified with the username pre-logon. You can then create policies for pre-logon users and although the user is not logged in directly,
their machines are authenticated on the domain as if they were fully logged in.

* ['known-user']: Includes all authenticated users, which means any IP with user data mapped. This option is equivalent to the domain users group on a domain.

* ['unknown']: Includes all unauthenticated users, which means IP addresses that are not mapped to a user. For example, you could use unknown for guest
level access to something because they will have an IP on your network but will not be authenticated to the domain and will not have IP
to user mapping information on the firewall.

* Or provide a list of specific users. E.g. ['admin','john.doe','jane.doe']

Note: If you are using a RADIUS server and not the User-ID agent, the list of users does not display; you must enter user information manually.
DESC
      default:     ['any'],
      xpath_array: 'source-user/member/text()',
    },
    hip_profiles: {
      type:        'Array[String]',
      desc:        <<DESC,
Specifiy one or more HIP profiles. A HIP enables you to collect information about the security status of your end hosts, such as whether they have the latest
security patches and antivirus definitions installed. Using host information profiles for policy enforcement enables granular security that ensures that the
remote hosts accessing your critical resources are adequately maintained and in adherence with your security standards before they are allowed access to your
network resources.
DESC
      default:     ['any'],
      xpath_array: 'hip-profiles/member/text()',
    },
    destination_zones:  {
      type:        'Array[String]',
      desc:        <<DESC,
Specify one or more destination zones. Zones must be of the same type (Layer 2, Layer 3, or virtual wire). To define new zones, refer to “Defining Security Zones”.
Multiple zones can be used to simplify management. For example, if you have three different internal zones (Marketing, Sales, and Public Relations) that are all
directed to the untrusted destination zone, you can create one rule that covers all cases.

Note: On intrazone rules, you cannot define a Destination Zone because these types of rules only match traffic with a source and a destination within the same zone.
To specify the zones that match an intrazone rule you only need to set the Source Zone.
DESC
      default:     ['any'],
      xpath_array: 'to/member/text()',
    },
    destination_address:  {
      type:        'Array[String]',
      desc:        'Specify one or more destination addresses, address groups or regions',
      default:     ['any'],
      xpath_array: 'destination/member/text()',
    },
    negate_destination:  {
      type:  'Optional[Boolean]',
      desc:  'Matches on the reverse of the `destination_address` value.',
      xpath: 'negate-destination/text()',
    },
    applications: {
      type:        'Array[String]',
      desc:        <<DESC,
Select specific applications for the security rule. If an application has multiple functions, you can select the overall application or individual functions.
If you select the overall application, all functions are included and the application definition is automatically updated as future functions are added.
DESC
      default:     ['any'],
      xpath_array: 'application/member/text()',
    },
    services: {
      type:        'Array[String]',
      desc:        <<DESC,
Select services to limit to specific TCP and/or UDP port numbers. The following values are valid:

* ['any']: The selected applications are allowed or denied on any protocol or port.

* ['application-default']: The selected applications are allowed or denied only on their default ports defined by Palo Alto Networks®.
This option is recommended for allow policies because it prevents applications from running on unusual ports and protocol which, if not
intentional, can be a sign of undesired application behavior and usage.

Note that when you use this option, the firewall still checks for all applications on all ports but, with this configuration, applications are only allowed on their default ports and protocols.

* A list of services. E.g. ['service-http', 'service-https', 'my_custom_service']
DESC
      default:     ['application-default'],
      xpath_array: 'service/member/text()',
    },
    categories: {
      type:        'Array[String]',
      desc:        <<DESC,
The destination URL categories. The following values are valid:

* ['any']: Allow or deny all sessions regardless of the URL category.

* A list of specific categories or custom categories. E.g ['gambling','malware','my_custom_category']
DESC
      default:     ['any'],
      xpath_array: 'category/member/text()',
    },
    action: {
      type:    'Enum["deny", "allow", "drop", "reset-client", "reset-server", "reset-both"]',
      desc:    <<DESC,
To specify the action for traffic that matches the attributes defined in a rule, select from the following actions:

* allow: Allows the traffic.

* deny: Blocks traffic, and enforces the default Deny Action defined for the application that is being denied. To view the deny action defined by default for an application,
view the application details in Objects > Applications. Because the default deny action varies by application, the firewall could block the session and send a reset for one
application, while it could drop the session silently for another application.

* drop: Silently drops the application. A TCP reset is not sent to the host/application, unless `ICMP Unreachable` is set to true.

* reset-client: Sends a TCP reset to the client-side device.

* reset-server: Sends a TCP reset to the server-side device.

* reset-both: Sends a TCP reset to both the client-side and server-side devices.
DESC
      default: 'allow',
      xpath:   'action/text()',
    },
    icmp_unreachable: {
      type:   'Optional[Boolean]',
      desc:   <<DESC,
Only available for Layer 3 interfaces. When you configure security policy to drop traffic or to reset the connection, the traffic does not reach the destination host.
In such cases, for all UDP traffic and for TCP traffic that is dropped, you can enable the firewall to send an ICMP Unreachable response to the source IP address from
where the traffic originated. Enabling this setting allows the source to gracefully close or clear the session and prevents applications from breaking.
DESC
      xpath:  'icmp-unreachable/text()',
    },
    log_start: {
      type:   'Optional[Boolean]',
      desc:   'Generates a traffic log entry for the start of a session ',
      xpath:  'log-start/text()',
    },
    log_end: {
      type:    'Optional[Boolean]',
      desc:    'Generates a traffic log entry for the end of a session',
      default: true,
      xpath:   'log-end/text()',
    },
    log_setting: {
      type:  'Optional[String]',
      desc:  <<DESC,
To forward the local traffic log and threat log entries to remote destinations, such as Panorama and syslog servers, specifiy which log forwarding profile should be used.
Note that the generation of threat log entries is determined by the security profiles.
DESC
      xpath: 'log-setting/text()',
    },
    profile_type:  {
      type:  'Optional[Enum["profiles", "group", "none"]]',
      desc:  'Specify which type of profile will be used.',
      xpath: 'local-name(profile-setting/*[1])',
    },
    group_profile: {
      type:  'Optional[String]',
      desc:  'Specify the group profile, can only be set when `profile_type` is `group`.',
      xpath: 'profile-setting/group/member/text()',
    },
    anti_virus_profile: {
      type:  'Optional[String]',
      desc:  'Specify the anti-virus profile, can only be set when `profile_type` is `profiles`. To unset specify `none`.',
      xpath: 'profile-setting/profiles/virus/member/text()',
    },
    url_filtering_profile: {
      type:  'Optional[String]',
      desc:  'Specify the URL filtering profile, can only be set when `profile_type` is `profiles`. To unset specify `none`.',
      xpath: 'profile-setting/profiles/url-filtering/member/text()',
    },
    data_filtering_profile: {
      type:  'Optional[String]',
      desc:  'Specify the data filtering profile, can only be set when `profile_type` is `profiles`. To unset specify `none`.',
      xpath: 'profile-setting/profiles/data-filtering/member/text()',
    },
    file_blocking_profile: {
      type:  'Optional[String]',
      desc:  'Specify the file blocking profile, can only be set when `profile_type` is `profiles`. To unset specify `none`.',
      xpath: 'profile-setting/profiles/file-blocking/member/text()',
    },
    spyware_profile: {
      type:  'Optional[String]',
      desc:  'Specify the spyware profile, can only be set when `profile_type` is `profiles`. To unset specify `none`.',
      xpath: 'profile-setting/profiles/spyware/member/text()',
    },
    vulnerability_profile: {
      type:  'Optional[String]',
      desc:  'Specify the vulnerability profile, can only be set when `profile_type` is `profiles`. To unset specify `none`.',
      xpath: 'profile-setting/profiles/vulnerability/member/text()',
    },
    wildfire_analysis_profile: {
      type:  'Optional[String]',
      desc:  'Specify the wildfire analysis profile, can only be set when `profile_type` is `profiles`. To unset specify `none`.',
      xpath: 'profile-setting/profiles/wildfire-analysis/member/text()',
    },
    schedule_profile: {
      type:  'Optional[String]',
      desc:  'Specify the schedule profile to limit the days and times when the rule is in effect',
      xpath: 'schedule/text()',
    },
    qos_type: {
      type:  'Optional[Enum["follow-c2s-flow", "ip-precedence", "ip-dscp", "none"]]',
      desc:  'Specify which QoS profile should be used to change the Quality of Service setting on packets matching the rule.',
      xpath: 'local-name(qos/marking/*[1])',
    },
    ip_dscp: {
      type:  'Optional[String]',
      desc:  'Specify the IP DSCP QoS marking setting, only if `qos_type` is `ip-dscp`.',
      xpath: 'qos/marking/ip-dscp/text()',
    },
    ip_precedence: {
      type:  'Optional[String]',
      desc:  'Specify the IP Precedence QoS marking setting, only if `qos_type` is `ip-precedence`.',
      xpath: 'qos/marking/ip-precedence/text()',
    },
    disable_server_response_inspection: {
      type:  'Optional[Boolean]',
      desc:  'To disable packet inspection from the server to the client, enable this option. This option may be useful under heavy server load conditions.',
      xpath: 'option/disable-server-response-inspection/text()',
    },
    disable: {
      type:  'Optional[Boolean]',
      desc:  'Specify if the security policy rule should be disabled.',
      xpath: 'disabled/text()',
    },
    insert_after: {
      type: 'Optional[String]',
      desc: <<DESC,
Specifies where the rule should be inserted.

* If specified with an empty string, the rule will be inserted at the TOP.
  NOTE: Only one rule should be set to top
* If a rule name is specified, the rule will be inserted after the given rule.
* If this attribute is omitted, the rule will be added at the bottom.
  NOTE: Rules cannot be moved to the bottom once created. Instead specify the rule name to insert after.
DESC
      xpath: 'preceding-sibling::entry[1]/@name',
    },
  },
  autobefore: {
    panos_commit: 'commit',
  },
  autorequire: {
    panos_security_policy_rule: '$insert_after',
  },
)
