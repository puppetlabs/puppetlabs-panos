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
      desc:      'The display-name of the security-policy-rule. Restricted to 31 characters on PAN-OS version < 8.1.0.',
      behaviour: :namevar,
      xpath:     'string(@name)',
    },
    ensure: {
      type:    'Enum[present, absent]',
      desc:    'Whether this resource should be present or absent on the target system.',
      default: 'present',
    },
    rule_type: {
      type:     'Enum["universal", "interzone", "intrazone"]',
      desc:     'Specifiy the type of rule.',
      default:  'universal',
      xpath:    'rule-type/text()',
    },
    description: {
      type:   'Optional[String]',
      desc:   'Provide a description of the service.',
      xpath:  'description/text()',
    },
    tags: {
      type:         'Optional[Array[String]]',
      desc:         'The Palo Alto tags to apply to this security_policy_rule. Do not confuse this with the `tag` metaparameter used to filter resource application.',
      xpath_array:  'tag/member/text()',
    },
    source_zones: {
      type:         'Array[String]',
      desc:         'The source zone profile list.',
      default:      ['any'],
      xpath_array:  'from/member/text()',
    },
    source_address:  {
      type:         'Array[String]',
      desc:         'The list of source addresses.',
      default:      ['any'],
      xpath_array:  'source/member/text()',
    },
    negate_source:  {
      type:   'Optional[Boolean]',
      desc:   'Matches on the reverse of the `source_address` value.',
      xpath:  'negate-source/text()',
    },
    source_users:  {
      type:         'Array[String]',
      desc:         'The source users list',
      default:      ['any'],
      xpath_array:  'source-user/member/text()',
    },
    hip_profiles: {
      type:         'Array[String]',
      desc:         'Specifiy the HIP profiles list.',
      default:      ['any'],
      xpath_array:  'hip-profiles/member/text()',
    },
    destination_zones:  {
      type:         'Array[String]',
      desc:         'The destination zone profile list.',
      default:      ['any'],
      xpath_array:  'to/member/text()',
    },
    destination_address:  {
      type:         'Array[String]',
      desc:         'The list of destination addresses.',
      default:      ['any'],
      xpath_array:  'destination/member/text()',
    },
    negate_destination:  {
      type:   'Optional[Boolean]',
      desc:   'Matches on the reverse of the `destination_address` value.',
      xpath:  'negate-destination/text()',
    },
    applications: {
      type:         'Array[String]',
      desc:         'The allowed applications list.',
      default:      ['any'],
      xpath_array:  'application/member/text()',
    },
    services: {
      type:         'Array[String]',
      desc:         'The destination services.',
      default:      ['application-default'],
      xpath_array:  'service/member/text()',
    },
    categories: {
      type:         'Array[String]',
      desc:         'The destination URL categories.',
      default:      ['any'],
      xpath_array:  'category/member/text()',
    },
    action: {
      type:     'Enum["deny", "allow", "drop", "reset-client", "reset-server", "reset-both"]',
      desc:     'Specifiy which action would be taken when the rule matches.',
      default:  'allow',
      xpath:    'action/text()',
    },
    icmp_unreachable: {
      type:   'Optional[Boolean]',
      desc:   'Specifiy the ICMP reachable status.',
      xpath:  'icmp-unreachable/text()',
    },
    log_start: {
      type:   'Optional[Boolean]',
      desc:   'Enable logging for start of session.',
      xpath:  'log-start/text()',
    },
    log_end: {
      type:     'Optional[Boolean]',
      desc:     'Enable logging for end of session.',
      default:  true,
      xpath:    'log-end/text()',
    },
    log_setting: {
      type:     'Optional[String]',
      desc:     'Specifiy which log forwarding profile should be used.',
      xpath:    'log-setting/text()',
    },
    profile_type:  {
      type:   'Optional[Enum["profiles", "group", "none"]]',
      desc:   'Specify which type of profile will be used.',
      xpath:  'local-name(profile-setting/*[1])',
    },
    group_profile: {
      type:   'Optional[String]',
      desc:   'Specify the group profile, can only be set when `profile_type` is `group`.',
      xpath:  'profile-setting/group/member/text()',
    },
    anti_virus_profile: {
      type:   'Optional[String]',
      desc:   'Specify the anti-virus profile, can only be set when `profile_type` is `profiles`. To unset specify `none`.',
      xpath:  'profile-setting/profiles/virus/member/text()',
    },
    url_filtering_profile: {
      type:   'Optional[String]',
      desc:   'Specify the URL filtering profile, can only be set when `profile_type` is `profiles`. To unset specify `none`.',
      xpath:  'profile-setting/profiles/url-filtering/member/text()',
    },
    data_filtering_profile: {
      type:   'Optional[String]',
      desc:   'Specify the data filtering profile, can only be set when `profile_type` is `profiles`. To unset specify `none`.',
      xpath:  'profile-setting/profiles/data-filtering/member/text()',
    },
    file_blocking_profile: {
      type:   'Optional[String]',
      desc:   'Specify the file blocking profile, can only be set when `profile_type` is `profiles`. To unset specify `none`.',
      xpath:  'profile-setting/profiles/file-blocking/member/text()',
    },
    spyware_profile: {
      type:   'Optional[String]',
      desc:   'Specify the spyware profile, can only be set when `profile_type` is `profiles`. To unset specify `none`.',
      xpath:  'profile-setting/profiles/spyware/member/text()',
    },
    vulnerability_profile: {
      type:   'Optional[String]',
      desc:   'Specify the vulnerability profile, can only be set when `profile_type` is `profiles`. To unset specify `none`.',
      xpath:  'profile-setting/profiles/vulnerability/member/text()',
    },
    wildfire_analysis_profile: {
      type:   'Optional[String]',
      desc:   'Specify the wildfire analysis profile, can only be set when `profile_type` is `profiles`. To unset specify `none`.',
      xpath:  'profile-setting/profiles/wildfire-analysis/member/text()',
    },
    schedule_profile: {
      type:   'Optional[String]',
      desc:   'Specify the schedule profile.',
      xpath:  'schedule/text()',
    },
    qos_type: {
      type:   'Optional[Enum["follow-c2s-flow", "ip-precedence", "ip-dscp", "none"]]',
      desc:   'Specify which QoS profile should be used.',
      xpath:  'local-name(qos/marking/*[1])',
    },
    ip_dscp: {
      type:   'Optional[String]',
      desc:   'Specify the IP DSCP QoS marking setting, only if `qos_type` is `ip-dscp`.',
      xpath:  'qos/marking/ip-dscp/text()',
    },
    ip_precedence: {
      type:   'Optional[String]',
      desc:   'Specify the IP Precedence QoS marking setting, only if `qos_type` is `ip-precedence`.',
      xpath:  'qos/marking/ip-precedence/text()',
    },
    disable_server_response_inspection: {
      type:     'Optional[Boolean]',
      desc:     'Specify if server response inspection should be enabled.',
      xpath:    'option/disable-server-response-inspection/text()',
    },
    disable: {
      type:     'Optional[Boolean]',
      desc:     'Specify if the security policy rule should be disabled.',
      xpath:    'disabled/text()',
    },
  },
  autobefore: {
    panos_commit: 'commit',
  },
)
