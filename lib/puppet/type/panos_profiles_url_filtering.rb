require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'panos_profiles_url_filtering',
  docs: <<-EOS,
This type provides Puppet with the capabilities to manage "url-filtering" profiles on Palo Alto devices.
EOS
  base_xpath: '/config/devices/entry/vsys/entry/profiles/url-filtering',
  features: ['remote_resource'],
  attributes: {
    name: {
      type:      'Pattern[/^[a-zA-z0-9\-_\s\.]{1,63}$/]',
      desc:      'The display-name of the url-filtering profile.',
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
      desc:      'Provide a description of this url-fitering profile.',
      xpath:     'description/text()',
    },
    credential_mode: {
      type:    'Enum["disabled", "ip-user", "domain-credentials", "group-mapping"]',
      desc:    <<DESC,
Specifies the Credential enforcement detection mode:

* group-mapping :       Use Group Mapping
* disabled :            Disabled
* domain-credentials :  Use Domain Credential Filter
* ip-user :             Use IP User Mapping

DESC
      default: 'disabled',
      xpath:   'credential-enforcement/mode/text()',
    },
    credential_block: {
      type:         'Optional[Array[String]]',
      desc:         'One or more `URL category` to block for credential enforcement.',
      xpath_array:  'credential-enforcement/block/member/text()',
    },
    credential_alert: {
      type:         'Optional[Array[String]]',
      desc:         'One or more `URL category` to trigger allert for credential enforcement.',
      xpath_array:  'credential-enforcement/alert/member/text()',
    },
    credential_allow: {
      type:         'Optional[Array[String]]',
      desc:         'One or more `URL category` to allow for credential enforcement.',
      xpath_array:  'credential-enforcement/allow/member/text()',
    },
    credential_continue: {
      type:         'Optional[Array[String]]',
      desc:         'One or more `URL category` to continue for credential enforcement.',
      xpath_array:  'credential-enforcement/continue/member/text()',
    },
    log_severity: {
      type:    'Enum["critical", "high", "informational", "low", "medium"]',
      desc:    <<DESC,
Specifies the Log severity for credential enforcement:
* critical        severity critical
* high            severity high
* informational   severity informational
* low             severity low
* medium          severity medium
DESC
      default: 'medium',
      xpath:   'credential-enforcement/log-severity/text()',
    },
    block: {
      type:         'Optional[Array[String]]',
      desc:         'One or more `URL category` to block access.',
      xpath_array:  'block/member/text()',
    },
    alert: {
      type:         'Optional[Array[String]]',
      desc:         'One or more `URL category` to trigger access alerts.',
      xpath_array:  'alert/member/text()',
    },
    allow: {
      type:         'Optional[Array[String]]',
      desc:         'One or more `URL category` to allow access.',
      xpath_array:  'allow/member/text()',
    },
    continue: {
      type:         'Optional[Array[String]]',
      desc:         'One or more `URL category` to block/continue.',
      xpath_array:  'continue/member/text()',
    },
    override: {
      type:         'Optional[Array[String]]',
      desc:         'One or more `URL category` to override access.',
      xpath_array:  'override/member/text()',
    },
    allow_list: {
      type:         'Optional[Array[String]]',
      desc:         'One or more specific URLs to allow access.',
      xpath_array:  'allow-list/member/text()',
    },
    block_list: {
      type:         'Optional[Array[String]]',
      desc:         'One or more specific URLs to block access.',
      xpath_array:  'block-list/member/text()',
    },
    action: {
      type:    'Enum["block", "alert", "continue", "override"]',
      desc:    <<DESC,
Specifies the Credential enforcement detection mode:

* block
* alert
* continue
* override

DESC
      default: 'block',
      xpath:   'action/text()',
    },
  },
  autobefore: {
    panos_commit: 'commit',
  },
)
