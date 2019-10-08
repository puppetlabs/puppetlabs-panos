require 'spec_helper'
require 'support/shared_examples'

module Puppet::Provider::PanosProfilesUrlFiltering; end
require 'puppet/provider/panos_profiles_url_filtering/panos_profiles_url_filtering'

RSpec.describe Puppet::Provider::PanosProfilesUrlFiltering::PanosProfilesUrlFiltering do
  subject(:provider) { described_class.new }

  test_data = [
    {
      descr: 'An exemple of URL Filtering profile',
      attrs: {
        name: 'url_profile_1',
        credential_mode: 'disabled',
        credential_block: [
          'questionable',
        ],
        credential_continue: [
          'weapons',
        ],
        credential_allow: [
          'adult',
        ],
        credential_alert: [
          'sex-education',
        ],
        block: [
          'adult',
        ],
        continue: [
          'internet-portals',
        ],
        allow: [
          'hunting-and-fishing',
        ],
        alert: [
          'weapons',
        ],
        override: [
          'nudity',
        ],
        allow_list: [
          'www.google.com',
        ],
        block_list: [
          'www.facebook.com',
        ],
      },
      xml:  '<entry name="url_profile_1">
              <credential-enforcement>
                <mode>
                  <disabled/>
                </mode>
                <block>
                  <member>questionable</member>
                </block>
                <continue>
                  <member>weapons</member>
                </continue>
                <allow>
                  <member>adult</member>
                </allow>
                <alert>
                  <member>sex-education</member>
                </alert>
                <log-severity>medium</log-severity>
              </credential-enforcement>
              <block>
                <member>adult</member>
              </block>
              <continue>
                <member>internet-portals</member>
              </continue>
              <allow>
                <member>hunting-and-fishing</member>
              </allow>
              <alert>
                <member>weapons</member>
              </alert>
              <override>
                <member>nudity</member>
              </override>
              <allow-list>
                <member>www.google.com</member>
              </allow-list>
              <block-list>
                <member>www.facebook.com</member>
              </block-list>
              <action>block</action>
            </entry>',
    },
  ]

  include_examples 'xml_from_should(name, should)', test_data, described_class.new
end
