require 'spec_helper'
require 'support/shared_examples'

module Puppet::Provider::PanosSecurityPolicyRule; end
require 'puppet/provider/panos_security_policy_rule/panos_security_policy_rule'

RSpec.describe Puppet::Provider::PanosSecurityPolicyRule::PanosSecurityPolicyRule do
  subject(:provider) { described_class.new }

  describe 'validate_should(should)' do
    context 'when destination_zones is not [`any`] for when rule type `intrazone`.' do
      let(:should_hash) do
        {
          name:               'non_any_destination_zone',
          rule_type:          'intrazone',
          destination_zones:  ['none', 'any', 'validation'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{Destination zone can only be \[`any`\] for rule_type `intrazone`.} }
    end
    context 'when destination_zones is not [`any`] for when rule type is not `intrazone`.' do
      let(:should_hash) do
        {
          name:               'non_any_destination_zone',
          rule_type:          'universal',
          destination_zones:  ['none', 'any', 'validation'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when destination_zones is [`any`] for when rule type `intrazone`.' do
      let(:should_hash) do
        {
          name:               'any_destination_zone',
          rule_type:          'intrazone',
          destination_zones:  ['any'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when `profile_type` is not `profiles` and `anti_virus_profile` is supplied.' do
      let(:should_hash) do
        {
          name:               'anti_virus_profile_while_profile_type_not_profiles',
          profile_type:       'group',
          anti_virus_profile: 'virus',
          rule_type:          'universal',
          destination_zones:  ['10.10.10.10'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{`anti_virus_profile` can only be supplied for `profile_type` `profiles`.} }
    end
    context 'when `profile_type` is `profiles` and `anti_virus_profile` is supplied.' do
      let(:should_hash) do
        {
          name:               'anti_virus_profile_while_profile_type_is_profiles',
          profile_type:       'profiles',
          anti_virus_profile: 'virus',
          rule_type:          'universal',
          destination_zones:  ['10.10.10.10'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when `profile_type` is not `profiles` and `url_filtering_profile` is supplied.' do
      let(:should_hash) do
        {
          name:                   'url_filtering_profile_while_profile_type_not_profiles',
          profile_type:           'group',
          url_filtering_profile:  'filtering profile',
          rule_type:              'universal',
          destination_zones:      ['10.10.10.10'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{`url_filtering_profile` can only be supplied for `profile_type` `profiles`.} }
    end
    context 'when `profile_type` is `profiles` and `url_filtering_profile` is supplied.' do
      let(:should_hash) do
        {
          name:                   'url_filtering_profile_while_profile_type_is_profiles',
          profile_type:           'profiles',
          url_filtering_profile:  'filtering profile',
          rule_type:              'universal',
          destination_zones:      ['10.10.10.10'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when `profile_type` is not `profiles` and `data_filtering_profile` is supplied.' do
      let(:should_hash) do
        {
          name:                     'data_filtering_profile_while_profile_type_not_profiles',
          profile_type:             'group',
          data_filtering_profile:   'filtering profile',
          rule_type:                'universal',
          destination_zones:        ['10.10.10.10'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{`data_filtering_profile` can only be supplied for `profile_type` `profiles`.} }
    end
    context 'when `profile_type` is `profiles` and `data_filtering_profile` is supplied.' do
      let(:should_hash) do
        {
          name:                     'data_filtering_profile_while_profile_type_is_profiles',
          profile_type:             'profiles',
          data_filtering_profile:   'filtering profile',
          rule_type:                'universal',
          destination_zones:        ['10.10.10.10'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when `profile_type` is not `profiles` and `file_blocking_profile` is supplied.' do
      let(:should_hash) do
        {
          name:                   'file_blocking_profile_while_profile_type_not_profiles',
          profile_type:           'group',
          file_blocking_profile:  'blocking profile',
          rule_type:              'universal',
          destination_zones:      ['10.10.10.10'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{`file_blocking_profile` can only be supplied for `profile_type` `profiles`.} }
    end
    context 'when `profile_type` is `profiles` and `file_blocking_profile` is supplied.' do
      let(:should_hash) do
        {
          name:                   'file_blocking_profile_while_profile_type_is_profiles',
          profile_type:           'profiles',
          file_blocking_profile:  'blocking profile',
          rule_type:              'universal',
          destination_zones:      ['10.10.10.10'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when `profile_type` is not `profiles` and `spyware_profile` is supplied.' do
      let(:should_hash) do
        {
          name:               'spyware_profile_while_profile_type_not_profiles',
          profile_type:       'group',
          spyware_profile:    'spyware profile',
          rule_type:          'universal',
          destination_zones:  ['10.10.10.10'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{`spyware_profile` can only be supplied for `profile_type` `profiles`.} }
    end
    context 'when `profile_type` is `profiles` and `spyware_profile` is supplied.' do
      let(:should_hash) do
        {
          name:               'spyware_profile_while_profile_type_is_profiles',
          profile_type:       'profiles',
          spyware_profile:    'spyware profile',
          rule_type:          'universal',
          destination_zones:  ['10.10.10.10'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when `profile_type` is not `profiles` and `vulnerability_profile` is supplied.' do
      let(:should_hash) do
        {
          name:                   'vulnerability_profile_while_profile_type_not_profiles',
          profile_type:           'group',
          vulnerability_profile:  'vulnerability profile',
          rule_type:              'universal',
          destination_zones:      ['10.10.10.10'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{`vulnerability_profile` can only be supplied for `profile_type` `profiles`.} }
    end
    context 'when `profile_type` is `profiles` and `vulnerability_profile` is supplied.' do
      let(:should_hash) do
        {
          name:                   'vulnerability_profile_while_profile_type_is_profiles',
          profile_type:           'profiles',
          vulnerability_profile:  'vulnerability profile',
          rule_type:              'universal',
          destination_zones:      ['10.10.10.10'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when `profile_type` is not `profiles` and `wildfire_analysis_profile` is supplied.' do
      let(:should_hash) do
        {
          name:                       'wildfire_analysis_profile_while_profile_type_not_profiles',
          profile_type:               'group',
          wildfire_analysis_profile:  'vulnerability profile',
          rule_type:                  'universal',
          destination_zones:          ['10.10.10.10'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{`wildfire_analysis_profile` can only be supplied for `profile_type` `profiles`.} }
    end
    context 'when `profile_type` is `profiles` and `wildfire_analysis_profile` is supplied.' do
      let(:should_hash) do
        {
          name:                       'wildfire_analysis_profile_while_profile_type_is_profiles',
          profile_type:               'profiles',
          wildfire_analysis_profile:  'vulnerability profile',
          rule_type:                  'universal',
          destination_zones:          ['10.10.10.10'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when `profile_type` is not `group` and `group_profile` is supplied.' do
      let(:should_hash) do
        {
          name:               'group_profile_while_profile_type_not_group',
          profile_type:       'profiles',
          group_profile:      'group profile',
          rule_type:          'universal',
          destination_zones:  ['10.10.10.10'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{`group_profile` can only be supplied for `profile_type` `group`.} }
    end
    context 'when `profile_type` is `group` and `group_profile` is supplied.' do
      let(:should_hash) do
        {
          name:               'group_profile_while_profile_type_is_group',
          profile_type:       'group',
          group_profile:      'group profile',
          rule_type:          'universal',
          destination_zones:  ['10.10.10.10'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when `qos_type` is not `ip-dscp` and `ip_dscp` is supplied.' do
      let(:should_hash) do
        {
          name:               'ip_dscp_supplied_when_qos_type_different',
          profile_type:       'group',
          group_profile:      'group profile',
          rule_type:          'universal',
          destination_zones:  ['10.10.10.10'],
          qos_type:           'follow-c2s-flow',
          ip_dscp:            'dscp',
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{`ip_dscp` can only be supplied for `qos_type` `ip_dscp`.} }
    end
    context 'when `qos_type` is `ip-dscp` and `ip_dscp` is not supplied.' do
      let(:should_hash) do
        {
          name:               'ip_dscp_not_supplied_when_qos_type_is_ipdscp',
          profile_type:       'group',
          group_profile:      'group profile',
          rule_type:          'universal',
          destination_zones:  ['10.10.10.10'],
          qos_type:           'ip-dscp',
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{`ip_dscp` needs to be supplied for `qos_type` `ip_dscp`.} }
    end
    context 'when `qos_type` is `ip-dscp` and `ip_dscp` is supplied.' do
      let(:should_hash) do
        {
          name:               'ip_dscp_supplied_when_qos_type_is_ipdscp',
          profile_type:       'group',
          group_profile:      'group profile',
          rule_type:          'universal',
          destination_zones:  ['10.10.10.10'],
          qos_type:           'ip-dscp',
          ip_dscp:            'dscp',
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when `qos_type` is not `ip-precedence` and `ip_precedence` is supplied.' do
      let(:should_hash) do
        {
          name:               'ip_precedence_supplied_when_qos_type_different',
          profile_type:       'group',
          group_profile:      'group profile',
          rule_type:          'universal',
          destination_zones:  ['10.10.10.10'],
          qos_type:           'follow-c2s-flow',
          ip_precedence:      'precedence',
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{`ip_precedence` can only be supplied for `qos_type` `ip_precedence`.} }
    end
    context 'when `qos_type` is `ip-precedence` and `ip_precedence` is not supplied.' do
      let(:should_hash) do
        {
          name:               'ip_precedence_not_supplied_when_qos_type_is_ip-precedence',
          profile_type:       'group',
          group_profile:      'group profile',
          rule_type:          'universal',
          destination_zones:  ['10.10.10.10'],
          qos_type:           'ip-precedence',
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{`ip_precedence` needs to be supplied for `qos_type` `ip_precedence`.} }
    end
    context 'when `qos_type` is `ip-precedence` and `ip_precedence` is supplied.' do
      let(:should_hash) do
        {
          name:               'ip_precedence_supplied_when_qos_type_is_ip-precedence',
          profile_type:       'group',
          group_profile:      'group profile',
          rule_type:          'universal',
          destination_zones:  ['10.10.10.10'],
          qos_type:           'ip-precedence',
          ip_precedence:      'ip',
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when `icmp_unreachable` is set to `true` and `action` is set to `allow`.' do
      let(:should_hash) do
        {
          name:               'icmp_unreachable_for_action_allow',
          profile_type:       'group',
          group_profile:      'group profile',
          rule_type:          'universal',
          destination_zones:  ['10.10.10.10'],
          action:             'allow',
          icmp_unreachable:   true,
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{`icmp_unreachable` cannot be `true` for `action` `allow`.} }
    end
    context 'when `icmp_unreachable` is set to `false` and `action` is set to `allow`.' do
      let(:should_hash) do
        {
          name:               'icmp_unreachable_for_action_allow',
          profile_type:       'group',
          group_profile:      'group profile',
          rule_type:          'universal',
          destination_zones:  ['10.10.10.10'],
          action:             'allow',
          icmp_unreachable:   false,
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when `icmp_unreachable` is set to `true` and `action` is set to `deny`.' do
      let(:should_hash) do
        {
          name:               'icmp_unreachable_for_action_deny',
          profile_type:       'group',
          group_profile:      'group profile',
          rule_type:          'universal',
          destination_zones:  ['10.10.10.10'],
          action:             'deny',
          icmp_unreachable:   true,
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{`icmp_unreachable` cannot be `true` for `action` `deny`.} }
    end
    context 'when `icmp_unreachable` is set to `false` and `action` is set to `deny`.' do
      let(:should_hash) do
        {
          name:               'icmp_unreachable_for_action_deny',
          profile_type:       'group',
          group_profile:      'group profile',
          rule_type:          'universal',
          destination_zones:  ['10.10.10.10'],
          action:             'deny',
          icmp_unreachable:   false,
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when `negate_source` is set to `true` and `source_zones` is set to [`any`].' do
      let(:should_hash) do
        {
          name:               'negate_source',
          profile_type:       'group',
          group_profile:      'group profile',
          rule_type:          'universal',
          destination_zones:  ['10.10.10.10'],
          action:             'deny',
          icmp_unreachable:   'false',
          negate_source:      true,
          source_zones:       ['any'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{`negate_source` cannot be set when `source_zones` is \[`any`\]} }
    end
    context 'when `negate_source` is set to `false` and `source_zones` is set to [`any`].' do
      let(:should_hash) do
        {
          name:               'negate_source',
          profile_type:       'group',
          group_profile:      'group profile',
          rule_type:          'universal',
          destination_zones:  ['10.10.10.10'],
          action:             'deny',
          icmp_unreachable:   'false',
          negate_source:      false,
          source_zones:       ['any'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when `negate_source` is set to `true` and `source_zones` is set to not [`any`].' do
      let(:should_hash) do
        {
          name:               'negate_source',
          profile_type:       'group',
          group_profile:      'group profile',
          rule_type:          'universal',
          destination_zones:  ['10.10.10.10'],
          action:             'deny',
          icmp_unreachable:   'false',
          negate_source:      true,
          source_zones:       ['10.10.10.10', '10.10.10.11'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when `negate_destination` is set to `true` and `destination_zones` is set to [`any`].' do
      let(:should_hash) do
        {
          name:               'negate_destination',
          profile_type:       'group',
          group_profile:      'group profile',
          rule_type:          'universal',
          destination_zones:  ['any'],
          action:             'deny',
          icmp_unreachable:   'false',
          negate_destination: true,
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{`negate_destination` cannot be set when `destination_zones` is \[`any`\]} }
    end
    context 'when `negate_destination` is set to `false` and `destination_zones` is set to [`any`].' do
      let(:should_hash) do
        {
          name:               'negate_destination',
          profile_type:       'group',
          group_profile:      'group profile',
          rule_type:          'universal',
          destination_zones:  ['any'],
          action:             'deny',
          icmp_unreachable:   'false',
          negate_destination: false,
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when `negate_destination` is set to `true` and `destination_zones` is set to not [`any`].' do
      let(:should_hash) do
        {
          name:               'negate_destination',
          profile_type:       'group',
          group_profile:      'group profile',
          rule_type:          'universal',
          destination_zones:  ['10.10.10.10', '10.10.10.11'],
          action:             'deny',
          icmp_unreachable:   'false',
          negate_destination: true,
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
  end

  test_data_for_xml_from_should = [
    {
      desc: 'an example with only compulsory elements.',
      attrs: {
        name:                 'only_compulsory_example',
        ensure:               'present',
        source_zones:         ['any'],
        source_address:       ['any'],
        source_users:         ['any'],
        hip_profiles:         ['any'],
        destination_zones:    ['any'],
        destination_address:  ['any'],
        applications:         ['any'],
        services:             ['application-default'],
        categories:           ['any'],
        action:               'allow',
      },
      xml:  '<entry name="only_compulsory_example">
              <to>
                <member>any</member>
              </to>
              <from>
                <member>any</member>
              </from>
              <source>
                <member>any</member>
              </source>
              <destination>
                <member>any</member>
              </destination>
              <source-user>
                <member>any</member>
              </source-user>
              <category>
                <member>any</member>
              </category>
              <application>
                <member>any</member>
              </application>
              <service>
                <member>application-default</member>
              </service>
              <hip-profiles>
                <member>any</member>
              </hip-profiles>
              <action>allow</action>
            </entry>',
    },
    {
      desc: 'an example with only compulsory elements with a description.',
      attrs: {
        name:                 'description_and_compulsory_example',
        ensure:               'present',
        rule_type:            'universal',
        description:          'this is a basic test description.',
        source_zones:         ['any'],
        source_address:       ['any'],
        source_users:         ['any'],
        hip_profiles:         ['any'],
        destination_zones:    ['multicast'],
        destination_address:  ['any'],
        applications:         ['any'],
        services:             ['application-default'],
        categories:           ['any'],
        action:               'allow',
      },
      xml:  '<entry name="description_and_compulsory_example">
              <to>
                <member>multicast</member>
              </to>
              <from>
                <member>any</member>
              </from>
              <source>
                <member>any</member>
              </source>
              <destination>
                <member>any</member>
              </destination>
              <source-user>
                <member>any</member>
              </source-user>
              <category>
                <member>any</member>
              </category>
              <application>
                <member>any</member>
              </application>
              <service>
                <member>application-default</member>
              </service>
              <hip-profiles>
                <member>any</member>
              </hip-profiles>
              <action>allow</action>
              <rule-type>universal</rule-type>
              <description>this is a basic test description.</description>
            </entry>',
    },
    {
      desc: 'an example with only compulsory elements with a description and tags.',
      attrs: {
        name:                 'tag_and_description_example',
        ensure:               'present',
        description:          'This is a test description highlighting the use of compulsory fields and tags, with this description.',
        tags:                 ['these', 'are', 'test', 'tags'],
        source_zones:         ['Source Zone'],
        source_address:       ['any'],
        source_users:         ['any'],
        hip_profiles:         ['any'],
        destination_zones:    ['Destination Zone'],
        destination_address:  ['any'],
        applications:         ['any'],
        services:             ['application-default'],
        categories:           ['any'],
        action:               'allow',
      },
      xml:  '<entry name="tag_and_description_example">
                <to>
                  <member>Destination Zone</member>
                </to>
                <from>
                  <member>Source Zone</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>any</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>any</member>
                </hip-profiles>
                <action>allow</action>
                <description>This is a test description highlighting the use of compulsory fields and tags, with this description.</description>
                <tag>
                  <member>these</member>
                  <member>are</member>
                  <member>test</member>
                  <member>tags</member>
                </tag>
              </entry>',
    },
    {
      desc: 'an example with only compulsory elements with a group profile set to `none`.',
      attrs: {
        name:                 'compulsory_fields_and_group_profile_example',
        ensure:               'present',
        source_zones:         ['any'],
        source_address:       ['any'],
        source_users:         ['any'],
        hip_profiles:         ['any'],
        destination_zones:    ['any'],
        destination_address:  ['any'],
        applications:         ['any'],
        services:             ['application-default'],
        categories:           ['any'],
        action:               'allow',
        profile_type:         'group',
      },
      xml:  '<entry name="compulsory_fields_and_group_profile_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>any</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>any</member>
                </hip-profiles>
                <action>allow</action>
                <profile-setting>
                  <group/>
                </profile-setting>
              </entry>',
    },
    {
      desc: 'an example with only compulsory elements with a group profile set to a profile.',
      attrs: {
        name:                 'compulsory_and_group_profile_set_example',
        ensure:               'present',
        source_zones:         ['any'],
        source_address:       ['any'],
        source_users:         ['any'],
        hip_profiles:         ['any'],
        destination_zones:    ['any'],
        destination_address:  ['any'],
        applications:         ['any'],
        services:             ['application-default'],
        categories:           ['any'],
        action:               'allow',
        profile_type:         'group',
        group_profile:        'test_group_profile',
      },
      xml:  '<entry name="compulsory_and_group_profile_set_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>any</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>any</member>
                </hip-profiles>
                <action>allow</action>
                <profile-setting>
                  <group>
                    <member>test_group_profile</member>
                  </group>
                </profile-setting>
              </entry>',
    },
    {
      desc: 'an example with no profiles set when `profile_type` is set to `profiles`.',
      attrs: {
        name:                 'profile_type_profiles_no_profiles_set_example',
        ensure:               'present',
        source_zones:         ['any'],
        source_address:       ['any'],
        source_users:         ['any'],
        hip_profiles:         ['any'],
        destination_zones:    ['any'],
        destination_address:  ['any'],
        applications:         ['any'],
        services:             ['application-default'],
        categories:           ['any'],
        action:               'allow',
        profile_type:         'profiles',
      },
      xml:  '<entry name="profile_type_profiles_no_profiles_set_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>any</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>any</member>
                </hip-profiles>
                <action>allow</action>
                <profile-setting>
                  <profiles/>
                </profile-setting>
              </entry>',
    },
    {
      desc: 'an example with a few profiles set when `profile_type` is set to `profiles`.',
      attrs: {
        name:                   'profile_type_few_profiles_set_example',
        ensure:                 'present',
        source_zones:           ['any'],
        source_address:         ['any'],
        source_users:           ['any'],
        hip_profiles:           ['any'],
        destination_zones:      ['any'],
        destination_address:    ['any'],
        applications:           ['any'],
        services:               ['application-default'],
        categories:             ['any'],
        action:                 'allow',
        profile_type:           'profiles',
        file_blocking_profile:  'strict file blocking',
        vulnerability_profile:  'New Vulnerability Protectio',
      },
      xml:  '<entry name="profile_type_few_profiles_set_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>any</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>any</member>
                </hip-profiles>
                <action>allow</action>
                <profile-setting>
                  <profiles>
                    <file-blocking>
                      <member>strict file blocking</member>
                    </file-blocking>
                    <vulnerability>
                      <member>New Vulnerability Protectio</member>
                    </vulnerability>
                  </profiles>
                </profile-setting>
              </entry>',
    },
    {
      desc: 'an example with all attributes for `profile_type` `profiles` filed in.',
      attrs: {
        name:                               'all_profiles_example',
        ensure:                             'present',
        rule_type:                          'universal',
        description:                        'This is a test description',
        tags:                               ['tags'],
        source_zones:                       ['any'],
        source_address:                     ['any'],
        negate_source:                      true,
        source_users:                       ['any'],
        hip_profiles:                       ['any'],
        destination_zones:                  ['any'],
        destination_address:                ['any'],
        negate_destination:                 true,
        applications:                       ['any'],
        services:                           ['application-default'],
        categories:                         ['any'],
        action:                             'allow',
        icmp_unreachable:                   false,
        log_start:                          true,
        log_end:                            true,
        log_setting:                        'n',
        profile_type:                       'profiles',
        anti_virus_profile:                 'Antivirus',
        url_filtering_profile:              'filtering',
        data_filtering_profile:             'datafilter',
        file_blocking_profile:              'fileblock',
        spyware_profile:                    'spyware',
        vulnerability_profile:              'New Vulnerability Protectio',
        wildfire_analysis_profile:          'wildfire',
        schedule_profile:                   'new schedule',
        qos_type:                           'ip-dscp',
        ip_dscp:                            'af21',
        disable_server_response_inspection: true,
      },
      xml:  '<entry name="all_profiles_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>any</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>any</member>
                </hip-profiles>
                <action>allow</action>
                <rule-type>universal</rule-type>
                <icmp-unreachable>no</icmp-unreachable>
                <option>
                  <disable-server-response-inspection>yes</disable-server-response-inspection>
                </option>
                <schedule>new schedule</schedule>
                <profile-setting>
                  <profiles>
                    <virus>
                      <member>Antivirus</member>
                    </virus>
                    <url-filtering>
                      <member>filtering</member>
                    </url-filtering>
                    <data-filtering>
                      <member>datafilter</member>
                    </data-filtering>
                    <file-blocking>
                      <member>fileblock</member>
                    </file-blocking>
                    <spyware>
                      <member>spyware</member>
                    </spyware>
                    <vulnerability>
                      <member>New Vulnerability Protectio</member>
                    </vulnerability>
                    <wildfire-analysis>
                      <member>wildfire</member>
                    </wildfire-analysis>
                  </profiles>
                </profile-setting>
                <log-setting>n</log-setting>
                <log-start>yes</log-start>
                <log-end>yes</log-end>
                <qos>
                  <marking>
                    <ip-dscp>af21</ip-dscp>
                  </marking>
                </qos>
                <description>This is a test description</description>
                <tag>
                  <member>tags</member>
                </tag>
                <negate-source>yes</negate-source>
                <negate-destination>yes</negate-destination>
              </entry>',
    },
    {
      desc: 'an example with all attributes except anti_virus_profile for `profile_type` `profiles` filed in.',
      attrs: {
        name:                               'all_profiles_example',
        ensure:                             'present',
        rule_type:                          'universal',
        description:                        'This is a test description',
        tags:                               ['tags'],
        source_zones:                       ['any'],
        source_address:                     ['any'],
        negate_source:                      true,
        source_users:                       ['any'],
        hip_profiles:                       ['any'],
        destination_zones:                  ['any'],
        destination_address:                ['any'],
        negate_destination:                 true,
        applications:                       ['any'],
        services:                           ['application-default'],
        categories:                         ['any'],
        action:                             'allow',
        icmp_unreachable:                   false,
        log_start:                          true,
        log_end:                            true,
        log_setting:                        'n',
        profile_type:                       'profiles',
        url_filtering_profile:              'filtering',
        data_filtering_profile:             'datafilter',
        file_blocking_profile:              'fileblock',
        spyware_profile:                    'spyware',
        vulnerability_profile:              'New Vulnerability Protectio',
        wildfire_analysis_profile:          'wildfire',
        schedule_profile:                   'new schedule',
        qos_type:                           'ip-dscp',
        ip_dscp:                            'af21',
        disable_server_response_inspection: true,
      },
      xml:  '<entry name="all_profiles_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>any</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>any</member>
                </hip-profiles>
                <action>allow</action>
                <rule-type>universal</rule-type>
                <icmp-unreachable>no</icmp-unreachable>
                <option>
                  <disable-server-response-inspection>yes</disable-server-response-inspection>
                </option>
                <schedule>new schedule</schedule>
                <profile-setting>
                  <profiles>
                    <url-filtering>
                      <member>filtering</member>
                    </url-filtering>
                    <data-filtering>
                      <member>datafilter</member>
                    </data-filtering>
                    <file-blocking>
                      <member>fileblock</member>
                    </file-blocking>
                    <spyware>
                      <member>spyware</member>
                    </spyware>
                    <vulnerability>
                      <member>New Vulnerability Protectio</member>
                    </vulnerability>
                    <wildfire-analysis>
                      <member>wildfire</member>
                    </wildfire-analysis>
                  </profiles>
                </profile-setting>
                <log-setting>n</log-setting>
                <log-start>yes</log-start>
                <log-end>yes</log-end>
                <qos>
                  <marking>
                    <ip-dscp>af21</ip-dscp>
                  </marking>
                </qos>
                <description>This is a test description</description>
                <tag>
                  <member>tags</member>
                </tag>
                <negate-source>yes</negate-source>
                <negate-destination>yes</negate-destination>
              </entry>',
    },
    {
      desc: 'an example with all attributes except anti_virus_profile for `profile_type` `profiles` filed in, `anti_virus_profile` set to `none`.',
      attrs: {
        name:                               'all_profiles_example',
        ensure:                             'present',
        rule_type:                          'universal',
        description:                        'This is a test description',
        tags:                               ['tags'],
        source_zones:                       ['any'],
        source_address:                     ['any'],
        negate_source:                      true,
        source_users:                       ['any'],
        hip_profiles:                       ['any'],
        destination_zones:                  ['any'],
        destination_address:                ['any'],
        negate_destination:                 true,
        applications:                       ['any'],
        services:                           ['application-default'],
        categories:                         ['any'],
        action:                             'allow',
        icmp_unreachable:                   false,
        log_start:                          true,
        log_end:                            true,
        log_setting:                        'n',
        profile_type:                       'profiles',
        anti_virus_profile:                 'none',
        url_filtering_profile:              'filtering',
        data_filtering_profile:             'datafilter',
        file_blocking_profile:              'fileblock',
        spyware_profile:                    'spyware',
        vulnerability_profile:              'New Vulnerability Protectio',
        wildfire_analysis_profile:          'wildfire',
        schedule_profile:                   'new schedule',
        qos_type:                           'ip-dscp',
        ip_dscp:                            'af21',
        disable_server_response_inspection: true,
      },
      xml:  '<entry name="all_profiles_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>any</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>any</member>
                </hip-profiles>
                <action>allow</action>
                <rule-type>universal</rule-type>
                <icmp-unreachable>no</icmp-unreachable>
                <option>
                  <disable-server-response-inspection>yes</disable-server-response-inspection>
                </option>
                <schedule>new schedule</schedule>
                <profile-setting>
                  <profiles>
                    <url-filtering>
                      <member>filtering</member>
                    </url-filtering>
                    <data-filtering>
                      <member>datafilter</member>
                    </data-filtering>
                    <file-blocking>
                      <member>fileblock</member>
                    </file-blocking>
                    <spyware>
                      <member>spyware</member>
                    </spyware>
                    <vulnerability>
                      <member>New Vulnerability Protectio</member>
                    </vulnerability>
                    <wildfire-analysis>
                      <member>wildfire</member>
                    </wildfire-analysis>
                  </profiles>
                </profile-setting>
                <log-setting>n</log-setting>
                <log-start>yes</log-start>
                <log-end>yes</log-end>
                <qos>
                  <marking>
                    <ip-dscp>af21</ip-dscp>
                  </marking>
                </qos>
                <description>This is a test description</description>
                <tag>
                  <member>tags</member>
                </tag>
                <negate-source>yes</negate-source>
                <negate-destination>yes</negate-destination>
              </entry>',
    },
    {
      desc: 'an example with all attributes except url_filtering_profile for `profile_type` `profiles` filed in.',
      attrs: {
        name:                               'all_profiles_example',
        ensure:                             'present',
        rule_type:                          'universal',
        description:                        'This is a test description',
        tags:                               ['tags'],
        source_zones:                       ['any'],
        source_address:                     ['any'],
        negate_source:                      true,
        source_users:                       ['any'],
        hip_profiles:                       ['any'],
        destination_zones:                  ['any'],
        destination_address:                ['any'],
        negate_destination:                 true,
        applications:                       ['any'],
        services:                           ['application-default'],
        categories:                         ['any'],
        action:                             'allow',
        icmp_unreachable:                   false,
        log_start:                          true,
        log_end:                            true,
        log_setting:                        'n',
        profile_type:                       'profiles',
        anti_virus_profile:                 'virus profile',
        data_filtering_profile:             'datafilter',
        file_blocking_profile:              'fileblock',
        spyware_profile:                    'spyware',
        vulnerability_profile:              'New Vulnerability Protectio',
        wildfire_analysis_profile:          'wildfire',
        schedule_profile:                   'new schedule',
        qos_type:                           'ip-dscp',
        ip_dscp:                            'af21',
        disable_server_response_inspection: true,
      },
      xml:  '<entry name="all_profiles_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>any</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>any</member>
                </hip-profiles>
                <action>allow</action>
                <rule-type>universal</rule-type>
                <icmp-unreachable>no</icmp-unreachable>
                <option>
                  <disable-server-response-inspection>yes</disable-server-response-inspection>
                </option>
                <schedule>new schedule</schedule>
                <profile-setting>
                  <profiles>
                    <virus>
                      <member>virus profile</member>
                    </virus>
                    <data-filtering>
                      <member>datafilter</member>
                    </data-filtering>
                    <file-blocking>
                      <member>fileblock</member>
                    </file-blocking>
                    <spyware>
                      <member>spyware</member>
                    </spyware>
                    <vulnerability>
                      <member>New Vulnerability Protectio</member>
                    </vulnerability>
                    <wildfire-analysis>
                      <member>wildfire</member>
                    </wildfire-analysis>
                  </profiles>
                </profile-setting>
                <log-setting>n</log-setting>
                <log-start>yes</log-start>
                <log-end>yes</log-end>
                <qos>
                  <marking>
                    <ip-dscp>af21</ip-dscp>
                  </marking>
                </qos>
                <description>This is a test description</description>
                <tag>
                  <member>tags</member>
                </tag>
                <negate-source>yes</negate-source>
                <negate-destination>yes</negate-destination>
              </entry>',
    },
    {
      desc: 'an example with all attributes except url_filtering_profile for `profile_type` `profiles` filed in, `url_filtering_profile` set to `none`.',
      attrs: {
        name:                               'all_profiles_example',
        ensure:                             'present',
        rule_type:                          'universal',
        description:                        'This is a test description',
        tags:                               ['tags'],
        source_zones:                       ['any'],
        source_address:                     ['any'],
        negate_source:                      true,
        source_users:                       ['any'],
        hip_profiles:                       ['any'],
        destination_zones:                  ['any'],
        destination_address:                ['any'],
        negate_destination:                 true,
        applications:                       ['any'],
        services:                           ['application-default'],
        categories:                         ['any'],
        action:                             'allow',
        icmp_unreachable:                   false,
        log_start:                          true,
        log_end:                            true,
        log_setting:                        'n',
        profile_type:                       'profiles',
        anti_virus_profile:                 'virus profile',
        url_filtering_profile:              'none',
        data_filtering_profile:             'datafilter',
        file_blocking_profile:              'fileblock',
        spyware_profile:                    'spyware',
        vulnerability_profile:              'New Vulnerability Protectio',
        wildfire_analysis_profile:          'wildfire',
        schedule_profile:                   'new schedule',
        qos_type:                           'ip-dscp',
        ip_dscp:                            'af21',
        disable_server_response_inspection: true,
      },
      xml:  '<entry name="all_profiles_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>any</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>any</member>
                </hip-profiles>
                <action>allow</action>
                <rule-type>universal</rule-type>
                <icmp-unreachable>no</icmp-unreachable>
                <option>
                  <disable-server-response-inspection>yes</disable-server-response-inspection>
                </option>
                <schedule>new schedule</schedule>
                <profile-setting>
                  <profiles>
                    <virus>
                      <member>virus profile</member>
                    </virus>
                    <data-filtering>
                      <member>datafilter</member>
                    </data-filtering>
                    <file-blocking>
                      <member>fileblock</member>
                    </file-blocking>
                    <spyware>
                      <member>spyware</member>
                    </spyware>
                    <vulnerability>
                      <member>New Vulnerability Protectio</member>
                    </vulnerability>
                    <wildfire-analysis>
                      <member>wildfire</member>
                    </wildfire-analysis>
                  </profiles>
                </profile-setting>
                <log-setting>n</log-setting>
                <log-start>yes</log-start>
                <log-end>yes</log-end>
                <qos>
                  <marking>
                    <ip-dscp>af21</ip-dscp>
                  </marking>
                </qos>
                <description>This is a test description</description>
                <tag>
                  <member>tags</member>
                </tag>
                <negate-source>yes</negate-source>
                <negate-destination>yes</negate-destination>
              </entry>',
    },
    {
      desc: 'an example with source and destination options negated.',
      attrs: {
        name:                 'negated_source_and_destination_example',
        ensure:               'present',
        source_zones:         ['any'],
        source_address:       ['any'],
        negate_source:        true,
        source_users:         ['any'],
        hip_profiles:         ['any'],
        destination_zones:    ['any'],
        destination_address:  ['any'],
        negate_destination:   true,
        applications:         ['any'],
        services:             ['application-default'],
        categories:           ['any'],
        action:               'allow',
      },
      xml:  '<entry name="negated_source_and_destination_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>any</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>any</member>
                </hip-profiles>
                <action>allow</action>
                <negate-source>yes</negate-source>
                <negate-destination>yes</negate-destination>
              </entry>',
    },
    {
      desc: 'an example with all attributes except data_filtering_profile for `profile_type` `profiles` filed in.',
      attrs: {
        name:                               'all_profiles_example',
        ensure:                             'present',
        rule_type:                          'universal',
        description:                        'This is a test description',
        tags:                               ['tags'],
        source_zones:                       ['any'],
        source_address:                     ['any'],
        negate_source:                      true,
        source_users:                       ['any'],
        hip_profiles:                       ['any'],
        destination_zones:                  ['any'],
        destination_address:                ['any'],
        negate_destination:                 true,
        applications:                       ['any'],
        services:                           ['application-default'],
        categories:                         ['any'],
        action:                             'allow',
        icmp_unreachable:                   false,
        log_start:                          true,
        log_end:                            true,
        log_setting:                        'n',
        profile_type:                       'profiles',
        anti_virus_profile:                 'Antivirus',
        url_filtering_profile:              'filtering',
        file_blocking_profile:              'fileblock',
        spyware_profile:                    'spyware',
        vulnerability_profile:              'New Vulnerability Protectio',
        wildfire_analysis_profile:          'wildfire',
        schedule_profile:                   'new schedule',
        qos_type:                           'ip-dscp',
        ip_dscp:                            'af21',
        disable_server_response_inspection: true,
      },
      xml:  '<entry name="all_profiles_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>any</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>any</member>
                </hip-profiles>
                <action>allow</action>
                <rule-type>universal</rule-type>
                <icmp-unreachable>no</icmp-unreachable>
                <option>
                  <disable-server-response-inspection>yes</disable-server-response-inspection>
                </option>
                <schedule>new schedule</schedule>
                <profile-setting>
                  <profiles>
                    <virus>
                      <member>Antivirus</member>
                    </virus>
                    <url-filtering>
                      <member>filtering</member>
                    </url-filtering>
                    <file-blocking>
                      <member>fileblock</member>
                    </file-blocking>
                    <spyware>
                      <member>spyware</member>
                    </spyware>
                    <vulnerability>
                      <member>New Vulnerability Protectio</member>
                    </vulnerability>
                    <wildfire-analysis>
                      <member>wildfire</member>
                    </wildfire-analysis>
                  </profiles>
                </profile-setting>
                <log-setting>n</log-setting>
                <log-start>yes</log-start>
                <log-end>yes</log-end>
                <qos>
                  <marking>
                    <ip-dscp>af21</ip-dscp>
                  </marking>
                </qos>
                <description>This is a test description</description>
                <tag>
                  <member>tags</member>
                </tag>
                <negate-source>yes</negate-source>
                <negate-destination>yes</negate-destination>
              </entry>',
    },
    {
      desc: 'an example with all attributes except data_filtering_profile for `profile_type` `profiles` filed in. `data_filtering_profile` set to `none`.',
      attrs: {
        name:                               'all_profiles_example',
        ensure:                             'present',
        rule_type:                          'universal',
        description:                        'This is a test description',
        tags:                               ['tags'],
        source_zones:                       ['any'],
        source_address:                     ['any'],
        negate_source:                      true,
        source_users:                       ['any'],
        hip_profiles:                       ['any'],
        destination_zones:                  ['any'],
        destination_address:                ['any'],
        negate_destination:                 true,
        applications:                       ['any'],
        services:                           ['application-default'],
        categories:                         ['any'],
        action:                             'allow',
        icmp_unreachable:                   false,
        log_start:                          true,
        log_end:                            true,
        log_setting:                        'n',
        profile_type:                       'profiles',
        anti_virus_profile:                 'Antivirus',
        url_filtering_profile:              'filtering',
        data_filtering_profile:             'none',
        file_blocking_profile:              'fileblock',
        spyware_profile:                    'spyware',
        vulnerability_profile:              'New Vulnerability Protectio',
        wildfire_analysis_profile:          'wildfire',
        schedule_profile:                   'new schedule',
        qos_type:                           'ip-dscp',
        ip_dscp:                            'af21',
        disable_server_response_inspection: true,
      },
      xml:  '<entry name="all_profiles_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>any</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>any</member>
                </hip-profiles>
                <action>allow</action>
                <rule-type>universal</rule-type>
                <icmp-unreachable>no</icmp-unreachable>
                <option>
                  <disable-server-response-inspection>yes</disable-server-response-inspection>
                </option>
                <schedule>new schedule</schedule>
                <profile-setting>
                  <profiles>
                    <virus>
                      <member>Antivirus</member>
                    </virus>
                    <url-filtering>
                      <member>filtering</member>
                    </url-filtering>
                    <file-blocking>
                      <member>fileblock</member>
                    </file-blocking>
                    <spyware>
                      <member>spyware</member>
                    </spyware>
                    <vulnerability>
                      <member>New Vulnerability Protectio</member>
                    </vulnerability>
                    <wildfire-analysis>
                      <member>wildfire</member>
                    </wildfire-analysis>
                  </profiles>
                </profile-setting>
                <log-setting>n</log-setting>
                <log-start>yes</log-start>
                <log-end>yes</log-end>
                <qos>
                  <marking>
                    <ip-dscp>af21</ip-dscp>
                  </marking>
                </qos>
                <description>This is a test description</description>
                <tag>
                  <member>tags</member>
                </tag>
                <negate-source>yes</negate-source>
                <negate-destination>yes</negate-destination>
              </entry>',
    },
    {
      desc: 'an example with source user set to unknown profile.',
      attrs: {
        name:                 'unknown_source_user_example',
        ensure:               'present',
        source_zones:         ['any'],
        source_address:       ['any'],
        source_users:         ['unknown'],
        hip_profiles:         ['any'],
        destination_zones:    ['any'],
        destination_address:  ['any'],
        applications:         ['any'],
        services:             ['application-default'],
        categories:           ['any'],
        action:               'allow',
      },
      xml:  '<entry name="unknown_source_user_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>unknown</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>any</member>
                </hip-profiles>
                <action>allow</action>
              </entry>',
    },
    {
      desc: 'an example with all attributes except file_blocking_profile for `profile_type` `profiles` filed in.',
      attrs: {
        name:                               'all_profiles_example',
        ensure:                             'present',
        rule_type:                          'universal',
        description:                        'This is a test description',
        tags:                               ['tags'],
        source_zones:                       ['any'],
        source_address:                     ['any'],
        negate_source:                      true,
        source_users:                       ['any'],
        hip_profiles:                       ['any'],
        destination_zones:                  ['any'],
        destination_address:                ['any'],
        negate_destination:                 true,
        applications:                       ['any'],
        services:                           ['application-default'],
        categories:                         ['any'],
        action:                             'allow',
        icmp_unreachable:                   false,
        log_start:                          true,
        log_end:                            true,
        log_setting:                        'n',
        profile_type:                       'profiles',
        anti_virus_profile:                 'Antivirus',
        url_filtering_profile:              'filtering',
        data_filtering_profile:             'datafilter',
        # file_blocking_profile:              'fileblock',
        spyware_profile:                    'spyware',
        vulnerability_profile:              'New Vulnerability Protectio',
        wildfire_analysis_profile:          'wildfire',
        schedule_profile:                   'new schedule',
        qos_type:                           'ip-dscp',
        ip_dscp:                            'af21',
        disable_server_response_inspection: true,
      },
      xml:  '<entry name="all_profiles_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>any</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>any</member>
                </hip-profiles>
                <action>allow</action>
                <rule-type>universal</rule-type>
                <icmp-unreachable>no</icmp-unreachable>
                <option>
                  <disable-server-response-inspection>yes</disable-server-response-inspection>
                </option>
                <schedule>new schedule</schedule>
                <profile-setting>
                  <profiles>
                    <virus>
                      <member>Antivirus</member>
                    </virus>
                    <url-filtering>
                      <member>filtering</member>
                    </url-filtering>
                    <data-filtering>
                      <member>datafilter</member>
                    </data-filtering>
                    <spyware>
                      <member>spyware</member>
                    </spyware>
                    <vulnerability>
                      <member>New Vulnerability Protectio</member>
                    </vulnerability>
                    <wildfire-analysis>
                      <member>wildfire</member>
                    </wildfire-analysis>
                  </profiles>
                </profile-setting>
                <log-setting>n</log-setting>
                <log-start>yes</log-start>
                <log-end>yes</log-end>
                <qos>
                  <marking>
                    <ip-dscp>af21</ip-dscp>
                  </marking>
                </qos>
                <description>This is a test description</description>
                <tag>
                  <member>tags</member>
                </tag>
                <negate-source>yes</negate-source>
                <negate-destination>yes</negate-destination>
              </entry>',
    },
    {
      desc: 'an example with all attributes except file_blocking_profile for `profile_type` `profiles` filed in. `file_blocking_profile` set to `none`.',
      attrs: {
        name:                               'all_profiles_example',
        ensure:                             'present',
        rule_type:                          'universal',
        description:                        'This is a test description',
        tags:                               ['tags'],
        source_zones:                       ['any'],
        source_address:                     ['any'],
        negate_source:                      true,
        source_users:                       ['any'],
        hip_profiles:                       ['any'],
        destination_zones:                  ['any'],
        destination_address:                ['any'],
        negate_destination:                 true,
        applications:                       ['any'],
        services:                           ['application-default'],
        categories:                         ['any'],
        action:                             'allow',
        icmp_unreachable:                   false,
        log_start:                          true,
        log_end:                            true,
        log_setting:                        'n',
        profile_type:                       'profiles',
        anti_virus_profile:                 'Antivirus',
        url_filtering_profile:              'filtering',
        data_filtering_profile:             'datafilter',
        file_blocking_profile:              'none',
        spyware_profile:                    'spyware',
        vulnerability_profile:              'New Vulnerability Protectio',
        wildfire_analysis_profile:          'wildfire',
        schedule_profile:                   'new schedule',
        qos_type:                           'ip-dscp',
        ip_dscp:                            'af21',
        disable_server_response_inspection: true,
      },
      xml:  '<entry name="all_profiles_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>any</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>any</member>
                </hip-profiles>
                <action>allow</action>
                <rule-type>universal</rule-type>
                <icmp-unreachable>no</icmp-unreachable>
                <option>
                  <disable-server-response-inspection>yes</disable-server-response-inspection>
                </option>
                <schedule>new schedule</schedule>
                <profile-setting>
                  <profiles>
                    <virus>
                      <member>Antivirus</member>
                    </virus>
                    <url-filtering>
                      <member>filtering</member>
                    </url-filtering>
                    <data-filtering>
                      <member>datafilter</member>
                    </data-filtering>
                    <spyware>
                      <member>spyware</member>
                    </spyware>
                    <vulnerability>
                      <member>New Vulnerability Protectio</member>
                    </vulnerability>
                    <wildfire-analysis>
                      <member>wildfire</member>
                    </wildfire-analysis>
                  </profiles>
                </profile-setting>
                <log-setting>n</log-setting>
                <log-start>yes</log-start>
                <log-end>yes</log-end>
                <qos>
                  <marking>
                    <ip-dscp>af21</ip-dscp>
                  </marking>
                </qos>
                <description>This is a test description</description>
                <tag>
                  <member>tags</member>
                </tag>
                <negate-source>yes</negate-source>
                <negate-destination>yes</negate-destination>
              </entry>',
    },
    {
      desc: 'an example with source user set to a source user profile.',
      attrs: {
        name:                 'source_user_example',
        ensure:               'present',
        rule_type:            'universal',
        source_zones:         ['any'],
        source_address:       ['any'],
        source_users:         ['source_user_test'],
        hip_profiles:         ['any'],
        destination_zones:    ['any'],
        destination_address:  ['any'],
        applications:         ['any'],
        services:             ['application-default'],
        categories:           ['any'],
        action:               'allow',
      },
      xml:  '<entry name="source_user_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>source_user_test</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>any</member>
                </hip-profiles>
                <action>allow</action>
                <rule-type>universal</rule-type>
              </entry>',
    },
    {
      desc: 'an example with all attributes except spyware_profile for `profile_type` `profiles` filed in.',
      attrs: {
        name:                               'all_profiles_example',
        ensure:                             'present',
        rule_type:                          'universal',
        description:                        'This is a test description',
        tags:                               ['tags'],
        source_zones:                       ['any'],
        source_address:                     ['any'],
        negate_source:                      true,
        source_users:                       ['any'],
        hip_profiles:                       ['any'],
        destination_zones:                  ['any'],
        destination_address:                ['any'],
        negate_destination:                 true,
        applications:                       ['any'],
        services:                           ['application-default'],
        categories:                         ['any'],
        action:                             'allow',
        icmp_unreachable:                   false,
        log_start:                          true,
        log_end:                            true,
        log_setting:                        'n',
        profile_type:                       'profiles',
        anti_virus_profile:                 'Antivirus',
        url_filtering_profile:              'filtering',
        data_filtering_profile:             'datafilter',
        file_blocking_profile:              'fileblock',
        # spyware_profile:                    'spyware',
        vulnerability_profile:              'New Vulnerability Protectio',
        wildfire_analysis_profile:          'wildfire',
        schedule_profile:                   'new schedule',
        qos_type:                           'ip-dscp',
        ip_dscp:                            'af21',
        disable_server_response_inspection: true,
      },
      xml:  '<entry name="all_profiles_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>any</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>any</member>
                </hip-profiles>
                <action>allow</action>
                <rule-type>universal</rule-type>
                <icmp-unreachable>no</icmp-unreachable>
                <option>
                  <disable-server-response-inspection>yes</disable-server-response-inspection>
                </option>
                <schedule>new schedule</schedule>
                <profile-setting>
                  <profiles>
                    <virus>
                      <member>Antivirus</member>
                    </virus>
                    <url-filtering>
                      <member>filtering</member>
                    </url-filtering>
                    <data-filtering>
                      <member>datafilter</member>
                    </data-filtering>
                    <file-blocking>
                      <member>fileblock</member>
                    </file-blocking>
                    <vulnerability>
                      <member>New Vulnerability Protectio</member>
                    </vulnerability>
                    <wildfire-analysis>
                      <member>wildfire</member>
                    </wildfire-analysis>
                  </profiles>
                </profile-setting>
                <log-setting>n</log-setting>
                <log-start>yes</log-start>
                <log-end>yes</log-end>
                <qos>
                  <marking>
                    <ip-dscp>af21</ip-dscp>
                  </marking>
                </qos>
                <description>This is a test description</description>
                <tag>
                  <member>tags</member>
                </tag>
                <negate-source>yes</negate-source>
                <negate-destination>yes</negate-destination>
              </entry>',
    },
    {
      desc: 'an example with all attributes except spyware_profile for `profile_type` `profiles` filed in. `spyware_profile` set to `none`.',
      attrs: {
        name:                               'all_profiles_example',
        ensure:                             'present',
        rule_type:                          'universal',
        description:                        'This is a test description',
        tags:                               ['tags'],
        source_zones:                       ['any'],
        source_address:                     ['any'],
        negate_source:                      true,
        source_users:                       ['any'],
        hip_profiles:                       ['any'],
        destination_zones:                  ['any'],
        destination_address:                ['any'],
        negate_destination:                 true,
        applications:                       ['any'],
        services:                           ['application-default'],
        categories:                         ['any'],
        action:                             'allow',
        icmp_unreachable:                   false,
        log_start:                          true,
        log_end:                            true,
        log_setting:                        'n',
        profile_type:                       'profiles',
        anti_virus_profile:                 'Antivirus',
        url_filtering_profile:              'filtering',
        data_filtering_profile:             'datafilter',
        file_blocking_profile:              'fileblock',
        spyware_profile:                    'none',
        vulnerability_profile:              'New Vulnerability Protectio',
        wildfire_analysis_profile:          'wildfire',
        schedule_profile:                   'new schedule',
        qos_type:                           'ip-dscp',
        ip_dscp:                            'af21',
        disable_server_response_inspection: true,
      },
      xml:  '<entry name="all_profiles_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>any</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>any</member>
                </hip-profiles>
                <action>allow</action>
                <rule-type>universal</rule-type>
                <icmp-unreachable>no</icmp-unreachable>
                <option>
                  <disable-server-response-inspection>yes</disable-server-response-inspection>
                </option>
                <schedule>new schedule</schedule>
                <profile-setting>
                  <profiles>
                    <virus>
                      <member>Antivirus</member>
                    </virus>
                    <url-filtering>
                      <member>filtering</member>
                    </url-filtering>
                    <data-filtering>
                      <member>datafilter</member>
                    </data-filtering>
                    <file-blocking>
                      <member>fileblock</member>
                    </file-blocking>
                    <vulnerability>
                      <member>New Vulnerability Protectio</member>
                    </vulnerability>
                    <wildfire-analysis>
                      <member>wildfire</member>
                    </wildfire-analysis>
                  </profiles>
                </profile-setting>
                <log-setting>n</log-setting>
                <log-start>yes</log-start>
                <log-end>yes</log-end>
                <qos>
                  <marking>
                    <ip-dscp>af21</ip-dscp>
                  </marking>
                </qos>
                <description>This is a test description</description>
                <tag>
                  <member>tags</member>
                </tag>
                <negate-source>yes</negate-source>
                <negate-destination>yes</negate-destination>
              </entry>',
    },
    {
      desc: 'an example with multiple source user profiles set.',
      attrs: {
        name:                 'multiple_source_users_example',
        ensure:               'present',
        source_zones:         ['any'],
        source_address:       ['any'],
        source_users:         ['source_user_test', 'source_user_test_2'],
        hip_profiles:         ['any'],
        destination_zones:    ['any'],
        destination_address:  ['any'],
        applications:         ['any'],
        services:             ['application-default'],
        categories:           ['any'],
        action:               'allow',
      },
      xml:  '<entry name="multiple_source_users_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>source_user_test</member>
                  <member>source_user_test_2</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>any</member>
                </hip-profiles>
                <action>allow</action>
              </entry>',
    },
    {
      desc: 'an example with all attributes except vulnerability_profile for `profile_type` `profiles` filed in.',
      attrs: {
        name:                               'all_profiles_example',
        ensure:                             'present',
        rule_type:                          'universal',
        description:                        'This is a test description',
        tags:                               ['tags'],
        source_zones:                       ['any'],
        source_address:                     ['any'],
        negate_source:                      true,
        source_users:                       ['any'],
        hip_profiles:                       ['any'],
        destination_zones:                  ['any'],
        destination_address:                ['any'],
        negate_destination:                 true,
        applications:                       ['any'],
        services:                           ['application-default'],
        categories:                         ['any'],
        action:                             'allow',
        icmp_unreachable:                   false,
        log_start:                          true,
        log_end:                            true,
        log_setting:                        'n',
        profile_type:                       'profiles',
        anti_virus_profile:                 'Antivirus',
        url_filtering_profile:              'filtering',
        data_filtering_profile:             'datafilter',
        file_blocking_profile:              'fileblock',
        spyware_profile:                    'spyware',
        # vulnerability_profile:              'New Vulnerability Protectio',
        wildfire_analysis_profile:          'wildfire',
        schedule_profile:                   'new schedule',
        qos_type:                           'ip-dscp',
        ip_dscp:                            'af21',
        disable_server_response_inspection: true,
      },
      xml:  '<entry name="all_profiles_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>any</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>any</member>
                </hip-profiles>
                <action>allow</action>
                <rule-type>universal</rule-type>
                <icmp-unreachable>no</icmp-unreachable>
                <option>
                  <disable-server-response-inspection>yes</disable-server-response-inspection>
                </option>
                <schedule>new schedule</schedule>
                <profile-setting>
                  <profiles>
                    <virus>
                      <member>Antivirus</member>
                    </virus>
                    <url-filtering>
                      <member>filtering</member>
                    </url-filtering>
                    <data-filtering>
                      <member>datafilter</member>
                    </data-filtering>
                    <file-blocking>
                      <member>fileblock</member>
                    </file-blocking>
                    <spyware>
                      <member>spyware</member>
                    </spyware>
                    <wildfire-analysis>
                      <member>wildfire</member>
                    </wildfire-analysis>
                  </profiles>
                </profile-setting>
                <log-setting>n</log-setting>
                <log-start>yes</log-start>
                <log-end>yes</log-end>
                <qos>
                  <marking>
                    <ip-dscp>af21</ip-dscp>
                  </marking>
                </qos>
                <description>This is a test description</description>
                <tag>
                  <member>tags</member>
                </tag>
                <negate-source>yes</negate-source>
                <negate-destination>yes</negate-destination>
              </entry>',
    },
    {
      desc: 'an example with all attributes except vulnerability_profile for `profile_type` `profiles` filed in. `vulnerability_profile` set to `none`.',
      attrs: {
        name:                               'all_profiles_example',
        ensure:                             'present',
        rule_type:                          'universal',
        description:                        'This is a test description',
        tags:                               ['tags'],
        source_zones:                       ['any'],
        source_address:                     ['any'],
        negate_source:                      true,
        source_users:                       ['any'],
        hip_profiles:                       ['any'],
        destination_zones:                  ['any'],
        destination_address:                ['any'],
        negate_destination:                 true,
        applications:                       ['any'],
        services:                           ['application-default'],
        categories:                         ['any'],
        action:                             'allow',
        icmp_unreachable:                   false,
        log_start:                          true,
        log_end:                            true,
        log_setting:                        'n',
        profile_type:                       'profiles',
        anti_virus_profile:                 'Antivirus',
        url_filtering_profile:              'filtering',
        data_filtering_profile:             'datafilter',
        file_blocking_profile:              'fileblock',
        spyware_profile:                    'spyware',
        vulnerability_profile:              'none',
        wildfire_analysis_profile:          'wildfire',
        schedule_profile:                   'new schedule',
        qos_type:                           'ip-dscp',
        ip_dscp:                            'af21',
        disable_server_response_inspection: true,
      },
      xml:  '<entry name="all_profiles_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>any</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>any</member>
                </hip-profiles>
                <action>allow</action>
                <rule-type>universal</rule-type>
                <icmp-unreachable>no</icmp-unreachable>
                <option>
                  <disable-server-response-inspection>yes</disable-server-response-inspection>
                </option>
                <schedule>new schedule</schedule>
                <profile-setting>
                  <profiles>
                    <virus>
                      <member>Antivirus</member>
                    </virus>
                    <url-filtering>
                      <member>filtering</member>
                    </url-filtering>
                    <data-filtering>
                      <member>datafilter</member>
                    </data-filtering>
                    <file-blocking>
                      <member>fileblock</member>
                    </file-blocking>
                    <spyware>
                      <member>spyware</member>
                    </spyware>
                    <wildfire-analysis>
                      <member>wildfire</member>
                    </wildfire-analysis>
                  </profiles>
                </profile-setting>
                <log-setting>n</log-setting>
                <log-start>yes</log-start>
                <log-end>yes</log-end>
                <qos>
                  <marking>
                    <ip-dscp>af21</ip-dscp>
                  </marking>
                </qos>
                <description>This is a test description</description>
                <tag>
                  <member>tags</member>
                </tag>
                <negate-source>yes</negate-source>
                <negate-destination>yes</negate-destination>
              </entry>',
    },
    {
      desc: 'an example with no HIP profile set.',
      attrs: {
        name:                 'no-hip_profile_set_example',
        ensure:               'present',
        source_zones:         ['any'],
        source_address:       ['any'],
        source_users:         ['any'],
        hip_profiles:         ['no-hip'],
        destination_zones:    ['any'],
        destination_address:  ['any'],
        applications:         ['any'],
        services:             ['application-default'],
        categories:           ['any'],
        action:               'allow',
      },
      xml:  '<entry name="no-hip_profile_set_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>any</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>no-hip</member>
                </hip-profiles>
                <action>allow</action>
              </entry>',
    },
    {
      desc: 'an example with all attributes except wildfire_analysis_profile for `profile_type` `profiles` filed in.',
      attrs: {
        name:                               'all_profiles_example',
        ensure:                             'present',
        rule_type:                          'universal',
        description:                        'This is a test description',
        tags:                               ['tags'],
        source_zones:                       ['any'],
        source_address:                     ['any'],
        negate_source:                      true,
        source_users:                       ['any'],
        hip_profiles:                       ['any'],
        destination_zones:                  ['any'],
        destination_address:                ['any'],
        negate_destination:                 true,
        applications:                       ['any'],
        services:                           ['application-default'],
        categories:                         ['any'],
        action:                             'allow',
        icmp_unreachable:                   false,
        log_start:                          true,
        log_end:                            true,
        log_setting:                        'n',
        profile_type:                       'profiles',
        anti_virus_profile:                 'Antivirus',
        url_filtering_profile:              'filtering',
        data_filtering_profile:             'datafilter',
        file_blocking_profile:              'fileblock',
        spyware_profile:                    'spyware',
        vulnerability_profile:              'New Vulnerability Protectio',
        # wildfire_analysis_profile:          'wildfire',
        schedule_profile:                   'new schedule',
        qos_type:                           'ip-dscp',
        ip_dscp:                            'af21',
        disable_server_response_inspection: true,
      },
      xml:  '<entry name="all_profiles_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>any</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>any</member>
                </hip-profiles>
                <action>allow</action>
                <rule-type>universal</rule-type>
                <icmp-unreachable>no</icmp-unreachable>
                <option>
                  <disable-server-response-inspection>yes</disable-server-response-inspection>
                </option>
                <schedule>new schedule</schedule>
                <profile-setting>
                  <profiles>
                    <virus>
                      <member>Antivirus</member>
                    </virus>
                    <url-filtering>
                      <member>filtering</member>
                    </url-filtering>
                    <data-filtering>
                      <member>datafilter</member>
                    </data-filtering>
                    <file-blocking>
                      <member>fileblock</member>
                    </file-blocking>
                    <spyware>
                      <member>spyware</member>
                    </spyware>
                    <vulnerability>
                      <member>New Vulnerability Protectio</member>
                    </vulnerability>
                  </profiles>
                </profile-setting>
                <log-setting>n</log-setting>
                <log-start>yes</log-start>
                <log-end>yes</log-end>
                <qos>
                  <marking>
                    <ip-dscp>af21</ip-dscp>
                  </marking>
                </qos>
                <description>This is a test description</description>
                <tag>
                  <member>tags</member>
                </tag>
                <negate-source>yes</negate-source>
                <negate-destination>yes</negate-destination>
              </entry>',
    },
    {
      desc: 'an example with all attributes except wildfire_analysis_profile for `profile_type` `profiles` filed in. `wildfire_analysis_profile` set to `none`.',
      attrs: {
        name:                               'all_profiles_example',
        ensure:                             'present',
        rule_type:                          'universal',
        description:                        'This is a test description',
        tags:                               ['tags'],
        source_zones:                       ['any'],
        source_address:                     ['any'],
        negate_source:                      true,
        source_users:                       ['any'],
        hip_profiles:                       ['any'],
        destination_zones:                  ['any'],
        destination_address:                ['any'],
        negate_destination:                 true,
        applications:                       ['any'],
        services:                           ['application-default'],
        categories:                         ['any'],
        action:                             'allow',
        icmp_unreachable:                   false,
        log_start:                          true,
        log_end:                            true,
        log_setting:                        'n',
        profile_type:                       'profiles',
        anti_virus_profile:                 'Antivirus',
        url_filtering_profile:              'filtering',
        data_filtering_profile:             'datafilter',
        file_blocking_profile:              'fileblock',
        spyware_profile:                    'spyware',
        vulnerability_profile:              'New Vulnerability Protectio',
        wildfire_analysis_profile:          'none',
        schedule_profile:                   'new schedule',
        qos_type:                           'ip-dscp',
        ip_dscp:                            'af21',
        disable_server_response_inspection: true,
      },
      xml:  '<entry name="all_profiles_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>any</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>any</member>
                </hip-profiles>
                <action>allow</action>
                <rule-type>universal</rule-type>
                <icmp-unreachable>no</icmp-unreachable>
                <option>
                  <disable-server-response-inspection>yes</disable-server-response-inspection>
                </option>
                <schedule>new schedule</schedule>
                <profile-setting>
                  <profiles>
                    <virus>
                      <member>Antivirus</member>
                    </virus>
                    <url-filtering>
                      <member>filtering</member>
                    </url-filtering>
                    <data-filtering>
                      <member>datafilter</member>
                    </data-filtering>
                    <file-blocking>
                      <member>fileblock</member>
                    </file-blocking>
                    <spyware>
                      <member>spyware</member>
                    </spyware>
                    <vulnerability>
                      <member>New Vulnerability Protectio</member>
                    </vulnerability>
                  </profiles>
                </profile-setting>
                <log-setting>n</log-setting>
                <log-start>yes</log-start>
                <log-end>yes</log-end>
                <qos>
                  <marking>
                    <ip-dscp>af21</ip-dscp>
                  </marking>
                </qos>
                <description>This is a test description</description>
                <tag>
                  <member>tags</member>
                </tag>
                <negate-source>yes</negate-source>
                <negate-destination>yes</negate-destination>
              </entry>',
    },
    {
      desc: 'an example with multiple HIP profiles set.',
      attrs: {
        name:                 'multiple_hip_profiles_example',
        ensure:               'present',
        source_zones:         ['any'],
        source_address:       ['any'],
        source_users:         ['any'],
        hip_profiles:         ['hip_profile_1', 'hip_profile_2'],
        destination_zones:    ['any'],
        destination_address:  ['any'],
        applications:         ['any'],
        services:             ['application-default'],
        categories:           ['any'],
        action:               'allow',
      },
      xml:  '<entry name="multiple_hip_profiles_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>any</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>hip_profile_1</member>
                  <member>hip_profile_2</member>
                </hip-profiles>
                <action>allow</action>
              </entry>',
    },
    {
      desc: 'an example with ICMP unreachable set.',
      attrs: {
        name:                 'icmp_unreachable_example',
        ensure:               'present',
        source_zones:         ['any'],
        source_address:       ['any'],
        source_users:         ['any'],
        hip_profiles:         ['any'],
        destination_zones:    ['any'],
        destination_address:  ['any'],
        applications:         ['any'],
        services:             ['application-default'],
        categories:           ['any'],
        action:               'reset-both',
        icmp_unreachable: true,
      },
      xml:  '<entry name="icmp_unreachable_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>any</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>any</member>
                </hip-profiles>
                <action>reset-both</action>
                <icmp-unreachable>yes</icmp-unreachable>
              </entry>',
    },
    {
      desc: 'an example with QoS setting set to IP DSCP.',
      attrs: {
        name:                 'qos_profile_set_to_ipdscp_example',
        ensure:               'present',
        source_zones:         ['any'],
        source_address:       ['any'],
        source_users:         ['any'],
        hip_profiles:         ['any'],
        destination_zones:    ['any'],
        destination_address:  ['any'],
        applications:         ['any'],
        services:             ['application-default'],
        categories:           ['any'],
        action:               'allow',
        qos_type:             'ip-dscp',
        ip_dscp:              'ef',
      },
      xml:  '<entry name="qos_profile_set_to_ipdscp_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>any</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>any</member>
                </hip-profiles>
                <action>allow</action>
                <qos>
                  <marking>
                    <ip-dscp>ef</ip-dscp>
                  </marking>
                </qos>
              </entry>',
    },
    {
      desc: 'an example with QoS setting set to IP Precdedence.',
      attrs: {
        name:                 'qos_profile_set_to_ipprecedence_example',
        ensure:               'present',
        source_zones:         ['any'],
        source_address:       ['any'],
        source_users:         ['any'],
        hip_profiles:         ['any'],
        destination_zones:    ['any'],
        destination_address:  ['any'],
        applications:         ['any'],
        services:             ['application-default'],
        categories:           ['any'],
        action:               'allow',
        qos_type:             'ip-precedence',
        ip_precedence:        'ef',
      },
      xml:  '<entry name="qos_profile_set_to_ipprecedence_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>any</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>any</member>
                </hip-profiles>
                <action>allow</action>
                <qos>
                  <marking>
                    <ip-precedence>ef</ip-precedence>
                  </marking>
                </qos>
              </entry>',
    },
    {
      desc: 'an example with QoS setting set to Follow Client 2 Server Flow.',
      attrs: {
        name:                 'qos_profile_set_to_followc2sflow_example',
        ensure:               'present',
        source_zones:         ['any'],
        source_address:       ['any'],
        source_users:         ['any'],
        hip_profiles:         ['any'],
        destination_zones:    ['any'],
        destination_address:  ['any'],
        applications:         ['any'],
        services:             ['application-default'],
        categories:           ['any'],
        action:               'allow',
        qos_type:             'follow-c2s-flow',
      },
      xml:  '<entry name="qos_profile_set_to_followc2sflow_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>any</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>any</member>
                </hip-profiles>
                <action>allow</action>
                <qos>
                  <marking>
                    <follow-c2s-flow/>
                  </marking>
                </qos>
              </entry>',
    },
    {
      desc: 'an example with disable server response insepction set to `yes`.',
      attrs: {
        name:                               'disable_server_inspection_selected_example',
        ensure:                             'present',
        source_zones:                       ['any'],
        source_address:                     ['any'],
        source_users:                       ['any'],
        hip_profiles:                       ['any'],
        destination_zones:                  ['any'],
        destination_address:                ['any'],
        applications:                       ['any'],
        services:                           ['application-default'],
        categories:                         ['any'],
        action:                             'allow',
        log_start:                          false,
        disable_server_response_inspection: true,
      },
      xml:  '<entry name="disable_server_inspection_selected_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>any</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>any</member>
                </hip-profiles>
                <action>allow</action>
                <option>
                  <disable-server-response-inspection>yes</disable-server-response-inspection>
                </option>
                <log-start>no</log-start>
              </entry>',
    },
    {
      desc: 'an example with `disable` set to `yes`.',
      attrs: {
        name:                               'disable_server_inspection_selected_example',
        ensure:                             'present',
        source_zones:                       ['any'],
        source_address:                     ['any'],
        source_users:                       ['any'],
        hip_profiles:                       ['any'],
        destination_zones:                  ['any'],
        destination_address:                ['any'],
        applications:                       ['any'],
        services:                           ['application-default'],
        categories:                         ['any'],
        action:                             'allow',
        log_start:                          false,
        disable_server_response_inspection: true,
        disable:                            true,
      },
      xml:  '<entry name="disable_server_inspection_selected_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>any</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>any</member>
                </hip-profiles>
                <action>allow</action>
                <option>
                  <disable-server-response-inspection>yes</disable-server-response-inspection>
                </option>
                <log-start>no</log-start>
                <disabled>yes</disabled>
              </entry>',
    },
    {
      desc: 'an example with `disable` set to `no`.',
      attrs: {
        name:                               'disable_server_inspection_selected_example',
        ensure:                             'present',
        source_zones:                       ['any'],
        source_address:                     ['any'],
        source_users:                       ['any'],
        hip_profiles:                       ['any'],
        destination_zones:                  ['any'],
        destination_address:                ['any'],
        applications:                       ['any'],
        services:                           ['application-default'],
        categories:                         ['any'],
        action:                             'allow',
        log_start:                          false,
        disable_server_response_inspection: true,
        disable:                            false,
      },
      xml:  '<entry name="disable_server_inspection_selected_example">
                <to>
                  <member>any</member>
                </to>
                <from>
                  <member>any</member>
                </from>
                <source>
                  <member>any</member>
                </source>
                <destination>
                  <member>any</member>
                </destination>
                <source-user>
                  <member>any</member>
                </source-user>
                <category>
                  <member>any</member>
                </category>
                <application>
                  <member>any</member>
                </application>
                <service>
                  <member>application-default</member>
                </service>
                <hip-profiles>
                  <member>any</member>
                </hip-profiles>
                <action>allow</action>
                <option>
                  <disable-server-response-inspection>yes</disable-server-response-inspection>
                </option>
                <log-start>no</log-start>
                <disabled>no</disabled>
              </entry>',
    },
  ]

  include_examples 'xml_from_should(name, should)', test_data_for_xml_from_should, described_class.new

  test_data_for_munge = [
    {
      desc: 'icmp_unreachable is `yes`.',
      entry:  {
        name:             'icmp_unreachable',
        icmp_unreachable: 'yes',
      },
      munged_entry: {
        name:             'icmp_unreachable',
        icmp_unreachable: true,
      },
    },
    {
      desc: 'icmp_unreachable is `no`.',
      entry:  {
        name:             'icmp_unreachable',
        icmp_unreachable: 'no',
      },
      munged_entry: {
        name:             'icmp_unreachable',
        icmp_unreachable: false,
      },
    },
    {
      desc: 'icmp_unreachable is neither `no` nor `yes`.',
      entry:  {
        name:             'icmp_unreachable',
        icmp_unreachable: 'neither',
      },
      munged_entry: {
        name:             'icmp_unreachable',
        icmp_unreachable: 'neither',
      },
    },
    {
      desc: 'log_start is `yes`.',
      entry:  {
        name:      'log_start',
        log_start: 'yes',
      },
      munged_entry: {
        name:      'log_start',
        log_start: true,
      },
    },
    {
      desc: 'log_start is `no`.',
      entry:  {
        name:      'log_start',
        log_start: 'no',
      },
      munged_entry: {
        name:      'log_start',
        log_start: false,
      },
    },
    {
      desc: 'log_start is neither `no` nor `yes`.',
      entry:  {
        name:      'log_start',
        log_start: 'neither',
      },
      munged_entry: {
        name:      'log_start',
        log_start: 'neither',
      },
    },
    {
      desc: 'log_end is `yes`.',
      entry:  {
        name:    'log_end',
        log_end: 'yes',
      },
      munged_entry: {
        name:    'log_end',
        log_end: true,
      },
    },
    {
      desc: 'log_end is `no`.',
      entry:  {
        name:    'log_end',
        log_end: 'no',
      },
      munged_entry: {
        name:    'log_end',
        log_end: false,
      },
    },
    {
      desc: 'log_end is neither `no` nor `yes`.',
      entry:  {
        name:    'log_end',
        log_end: 'neither',
      },
      munged_entry: {
        name:    'log_end',
        log_end: 'neither',
      },
    },
    {
      desc: 'disable_server_response_inspection is `yes`.',
      entry:  {
        name:                               'disable_server_response_inspection',
        disable_server_response_inspection: 'yes',
      },
      munged_entry: {
        name:                               'disable_server_response_inspection',
        disable_server_response_inspection: true,
      },
    },
    {
      desc: 'disable_server_response_inspection is `no`.',
      entry:  {
        name:                               'disable_server_response_inspection',
        disable_server_response_inspection: 'no',
      },
      munged_entry: {
        name:                               'disable_server_response_inspection',
        disable_server_response_inspection: false,
      },
    },
    {
      desc: 'disable_server_response_inspection is neither `no` nor `yes`.',
      entry:  {
        name:                               'disable_server_response_inspection',
        disable_server_response_inspection: 'neither',
      },
      munged_entry: {
        name:                               'disable_server_response_inspection',
        disable_server_response_inspection: 'neither',
      },
    },
    {
      desc: 'negate_source is `yes`.',
      entry:  {
        name:          'negate_source',
        negate_source: 'yes',
      },
      munged_entry: {
        name:          'negate_source',
        negate_source: true,
      },
    },
    {
      desc: 'negate_source is `no`.',
      entry:  {
        name:          'negate_source',
        negate_source: 'no',
      },
      munged_entry: {
        name:          'negate_source',
        negate_source: false,
      },
    },
    {
      desc: 'negate_source is neither `no` nor `yes`.',
      entry:  {
        name:          'negate_source',
        negate_source: 'neither',
      },
      munged_entry: {
        name:          'negate_source',
        negate_source: 'neither',
      },
    },
    {
      desc: 'negate_destination is `yes`.',
      entry:  {
        name:               'negate_destination',
        negate_destination: 'yes',
      },
      munged_entry: {
        name:               'negate_destination',
        negate_destination: true,
      },
    },
    {
      desc: 'negate_destination is `no`.',
      entry:  {
        name:               'negate_destination',
        negate_destination: 'no',
      },
      munged_entry: {
        name:               'negate_destination',
        negate_destination: false,
      },
    },
    {
      desc: 'negate_destination is neither `no` nor `yes`.',
      entry:  {
        name:               'negate_destination',
        negate_destination: 'neither',
      },
      munged_entry: {
        name:               'negate_destination',
        negate_destination: 'neither',
      },
    },
    {
      desc: 'disable is `yes`.',
      entry:  {
        name:    'disable',
        disable: 'yes',
      },
      munged_entry: {
        name:    'disable',
        disable: true,
      },
    },
    {
      desc: 'disable is `no`.',
      entry:  {
        name:    'disable',
        disable: 'no',
      },
      munged_entry: {
        name:    'disable',
        disable: false,
      },
    },
    {
      desc: 'disable is neither `no` nor `yes`.',
      entry:  {
        name:    'disable',
        disable: 'neither',
      },
      munged_entry: {
        name:    'disable',
        disable: 'neither',
      },
    },
    {
      desc: 'qos_type is nil.',
      entry:  {
        name:     'qos_type',
        qos_type: nil,
      },
      munged_entry: {
        name:     'qos_type',
        qos_type: 'none',
      },
    },
    {
      desc: 'qos_type is a value.',
      entry:  {
        name:     'qos_type',
        qos_type: 'follow-c2s-flow',
      },
      munged_entry: {
        name:     'qos_type',
        qos_type: 'follow-c2s-flow',
      },
    },
    {
      desc: 'anti_virus_profile is nil.',
      entry:  {
        name:               'anti_virus_profile',
        anti_virus_profile: nil,
      },
      munged_entry: {
        name:               'anti_virus_profile',
        anti_virus_profile: 'none',
      },
    },
    {
      desc: 'anti_virus_profile is a value.',
      entry:  {
        name:     'anti_virus_profile',
        anti_virus_profile: 'profile',
      },
      munged_entry: {
        name:               'anti_virus_profile',
        anti_virus_profile: 'profile',
      },
    },
    {
      desc: 'url_filtering_profile is nil.',
      entry:  {
        name:                   'url_filtering_profile',
        url_filtering_profile:  nil,
      },
      munged_entry: {
        name:                   'url_filtering_profile',
        url_filtering_profile:  'none',
      },
    },
    {
      desc: 'url_filtering_profile is a value.',
      entry:  {
        name:                   'url_filtering_profile',
        url_filtering_profile:  'profile',
      },
      munged_entry: {
        name:                   'url_filtering_profile',
        url_filtering_profile:  'profile',
      },
    },
    {
      desc: 'data_filtering_profile is nil.',
      entry:  {
        name:                   'data_filtering_profile',
        data_filtering_profile: nil,
      },
      munged_entry: {
        name:                   'data_filtering_profile',
        data_filtering_profile: 'none',
      },
    },
    {
      desc: 'data_filtering_profile is a value.',
      entry:  {
        name:                   'data_filtering_profile',
        data_filtering_profile: 'profile',
      },
      munged_entry: {
        name:                   'data_filtering_profile',
        data_filtering_profile: 'profile',
      },
    },
    {
      desc: 'file_blocking_profile is nil.',
      entry:  {
        name:                   'file_blocking_profile',
        file_blocking_profile:  nil,
      },
      munged_entry: {
        name:                   'file_blocking_profile',
        file_blocking_profile:  'none',
      },
    },
    {
      desc: 'file_blocking_profile is a value.',
      entry:  {
        name:                   'file_blocking_profile',
        file_blocking_profile:  'profile',
      },
      munged_entry: {
        name:                   'file_blocking_profile',
        file_blocking_profile:  'profile',
      },
    },
    {
      desc: 'spyware_profile is nil.',
      entry:  {
        name:             'spyware_profile',
        spyware_profile:  nil,
      },
      munged_entry: {
        name:             'spyware_profile',
        spyware_profile:  'none',
      },
    },
    {
      desc: 'spyware_profile is a value.',
      entry:  {
        name:             'spyware_profile',
        spyware_profile:  'profile',
      },
      munged_entry: {
        name:             'spyware_profile',
        spyware_profile:  'profile',
      },
    },
    {
      desc: 'vulnerability_profile is nil.',
      entry:  {
        name:                   'vulnerability_profile',
        vulnerability_profile:  nil,
      },
      munged_entry: {
        name:                   'vulnerability_profile',
        vulnerability_profile:  'none',
      },
    },
    {
      desc: 'vulnerability_profile is a value.',
      entry:  {
        name:                   'vulnerability_profile',
        vulnerability_profile:  'profile',
      },
      munged_entry: {
        name:                   'vulnerability_profile',
        vulnerability_profile:  'profile',
      },
    },
    {
      desc: 'wildfire_analysis_profile is nil.',
      entry:  {
        name:                       'wildfire_analysis_profile',
        wildfire_analysis_profile:  nil,
      },
      munged_entry: {
        name:                       'wildfire_analysis_profile',
        wildfire_analysis_profile:  'none',
      },
    },
    {
      desc: 'wildfire_analysis_profile is a value.',
      entry:  {
        name:                       'wildfire_analysis_profile',
        wildfire_analysis_profile:  'profile',
      },
      munged_entry: {
        name:                       'wildfire_analysis_profile',
        wildfire_analysis_profile:  'profile',
      },
    },
  ]

  include_examples 'munge(entry)', test_data_for_munge, described_class.new
end
