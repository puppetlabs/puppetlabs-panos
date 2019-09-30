require 'spec_helper'
require 'support/shared_examples'

module Puppet::Provider::PanosDecryptionPolicyRule; end
require 'puppet/provider/panos_decryption_policy_rule/panos_decryption_policy_rule'

RSpec.describe Puppet::Provider::PanosDecryptionPolicyRule::PanosDecryptionPolicyRule do
  subject(:provider) { described_class.new }

  describe 'validate_should(should)' do
    context 'when `negate_source` is set to `true` and `source_zones` is set to [`any`].' do
      let(:should_hash) do
        {
          name:               'negate_source',
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
          destination_zones:  ['any'],
          negate_destination: true,
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{`negate_destination` cannot be set when `destination_zones` is \[`any`\]} }
    end
    context 'when `negate_destination` is set to `false` and `destination_zones` is set to [`any`].' do
      let(:should_hash) do
        {
          name:               'negate_destination',
          destination_zones:  ['any'],
          negate_destination: false,
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when `negate_destination` is set to `true` and `destination_zones` is set to not [`any`].' do
      let(:should_hash) do
        {
          name:               'negate_destination',
          destination_zones:  ['10.10.10.10', '10.10.10.11'],
          negate_destination: true,
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
  end

  test_data_for_xml_from_should = [
    {
      desc: 'an example with only compulsory elements with a description.',
      attrs: {
        name:                 'description_and_compulsory_example',
        ensure:               'present',
        description:          'this is a basic test description.',
        tags:                 ['these', 'are', 'test', 'tags'],
        source_zones:         ['any'],
        source_address:       ['any'],
        source_users:         ['any'],
        destination_zones:    ['multicast'],
        destination_address:  ['any'],
        services:             ['application-default'],
        categories:           ['any'],
        action:               'nodecrypt',
        type:                 'ssl-forward-proxy',
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
              <service>
                <member>application-default</member>
              </service>
              <action>nodecrypt</action>
              <type><ssl-forward-proxy/></type>
              <description>this is a basic test description.</description>
                <tag>
                  <member>these</member>
                  <member>are</member>
                  <member>test</member>
                  <member>tags</member>
                </tag>
            </entry>',
    },
  ]

  include_examples 'xml_from_should(name, should)', test_data_for_xml_from_should, described_class.new

  test_data_for_munge = [
    {
      desc: 'negate_source is `yes`.',
      entry:  {
        name:          'negate_source',
        negate_source: 'yes',
      },
      munged_entry: {
        name:          'negate_source',
        negate_source: true,
        type:          'ssl-forward-proxy',
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
        type:          'ssl-forward-proxy',
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
        type:          'ssl-forward-proxy',
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
        type:          'ssl-forward-proxy',
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
        type:          'ssl-forward-proxy',
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
        type:          'ssl-forward-proxy',
      },
    },
    {
      desc: 'disable is `yes`.',
      entry:  {
        name:    'disable',
        disable: 'yes',
      },
      munged_entry: {
        name:       'disable',
        disable:    true,
        type:          'ssl-forward-proxy',
      },
    },
    {
      desc: 'disable is `no`.',
      entry:  {
        name:    'disable',
        disable: 'no',
      },
      munged_entry: {
        name:       'disable',
        disable:    false,
        type:          'ssl-forward-proxy',
      },
    },
    {
      desc: 'disable is neither `no` nor `yes`.',
      entry:  {
        name:    'disable',
        disable: 'neither',
      },
      munged_entry: {
        name:       'disable',
        disable:    'neither',
        type:          'ssl-forward-proxy',
      },
    },
    {
      desc: 'insert_after is nil.',
      entry:  {
        name:             'entry_at_top',
        insert_after:     nil,
      },
      munged_entry: {
        name:             'entry_at_top',
        insert_after:     '',
        type:          'ssl-forward-proxy',
      },
    },
  ]

  include_examples 'munge(entry)', test_data_for_munge, described_class.new
end
