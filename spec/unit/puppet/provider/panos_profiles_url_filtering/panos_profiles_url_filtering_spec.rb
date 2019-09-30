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
        alert: [
          'weapons',
        ],
        block: [
          'adult',
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
                <log-severity>medium</log-severity>
              </credential-enforcement>
              <block>
                <member>adult</member>
              </block>
              <alert>
                <member>weapons</member>
              </alert>
              <action>block</action>
            </entry>',
    },
  ]

  include_examples 'xml_from_should(name, should)', test_data, described_class.new
end
