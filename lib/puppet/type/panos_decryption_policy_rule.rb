# coding: utf-8
require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'panos_decryption_policy_rule',
  docs: <<-EOS,
This type provides Puppet with the capilities to manage "Decryption Policy Rules" on Palo Alto devices.
EOS
  base_xpath: '/config/devices/entry/vsys/entry/rulebase/decryption/rules',
  features: ['remote_resource'],
  attributes: {
    name: {
      type:      'Pattern[/^[a-zA-z0-9\-_\s\.]{1,63}$/]',
      desc:      'The display-name of the decryption-policy-rule. Restricted to 31 characters on PAN-OS version 7.1.0.',
      behaviour: :namevar,
      xpath:     'string(@name)',
    },
    ensure: {
      type:    'Enum[present, absent]',
      desc:    'Whether this resource should be present or absent on the target system.',
      default: 'present',
    },
    type: {
      type:    'Enum["ssl-forward-proxy", "ssh-proxy", "ssl-inbound-inspection"]',
      desc:    <<DESC,
Specifies the type of decryption rule:
DESC
      default: 'ssl-forward-proxy',
      xpath:   'type/text()',
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
      type:    'Enum["decrypt", "no-decrypt"]',
      desc:    <<DESC,
To specify the action for traffic that matches the attributes defined in a rule, select from the following actions:

* no-ecrypt: Do not decrypt the traffic.

* decrypt: Decrypt the traffic.
DESC
      default: 'no-decrypt',
      xpath:   'action/text()',
    },
    profile: {
      type:  'Optional[String]',
      desc:  'Specify the decryption profile, can only be set when `action` is `decrypt`.',
      xpath: 'profile/text()',
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
    panos_decryption_policy_rule: '$insert_after',
  },
)
