require 'spec_helper'
require 'support/shared_examples'

module Puppet::Provider::PanosAddressGroup; end
require 'puppet/provider/panos_address_group/panos_address_group'

RSpec.describe Puppet::Provider::PanosAddressGroup::PanosAddressGroup do
  subject(:provider) { described_class.new }

  describe 'validate_should(should)' do
    context 'when type is static and should contains static_members' do
      let(:should_hash) do
        {
          name: 'demo_group',
          ensure: 'present',
          description: 'static test address group',
          type: 'static',
          static_members: ['demo_group_dynamic'],
          tags: ['foo', 'wibble'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when type is static and should does not contain static_members' do
      let(:should_hash) do
        {
          name: 'demo_group',
          ensure: 'present',
          description: 'static test address group',
          type: 'static',
          tags: ['foo', 'wibble'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{Static Address group must provide `static_members`} }
    end
    context 'when type is dynamic and should contains dynamic_filter' do
      let(:should_hash) do
        {
          name: 'demo_group_dynamic',
          ensure: 'present',
          description: 'dynamic test address group',
          type: 'dynamic',
          dynamic_filter: '\'foo\' or \'wibble\' and \'bar\' ',
          tags: ['foo', 'bar'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when type is dynamic and should does not contain dynamic_filter' do
      let(:should_hash) do
        {
          name: 'demo_group_dynamic',
          ensure: 'present',
          description: 'dynamic test address group',
          type: 'dynamic',
          tags: ['foo', 'bar'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{Dynamic Address group must provide `dynamic_filter`} }
    end
  end

  test_data = [
    {
      desc: 'an example of a dynamic_group',
      attrs: {
        name:           'dynamic_group',
        ensure:         'present',
        description:    'dynamic test address group',
        type:           'dynamic',
        dynamic_filter: '\'foo\' or \'wibble\' and \'bar\' ',
        tags:           ['foo', 'bar'],
      },
      xml:  '<entry name="dynamic_group">
              <description>dynamic test address group</description>
              <dynamic>
                <filter>\'foo\' or \'wibble\' and \'bar\' </filter>
              </dynamic>
              <tag>
                <member>foo</member>
                <member>bar</member>
              </tag>
            </entry>',
    },
    {
      desc: 'an example of a static_group',
      attrs: {
        name:           'static_group',
        ensure:         'present',
        description:    'static test address group',
        type:           'static',
        static_members: ['demo_group_dynamic'],
        tags:           ['foo', 'wibble'],
      },
      xml:  '<entry name="static_group">
              <description>static test address group</description>
              <static>
                <member>demo_group_dynamic</member>
              </static>
              <tag>
                <member>foo</member>
                <member>wibble</member>
              </tag>
            </entry>',
    },
  ]

  include_examples 'xml_from_should(name, should)', test_data, described_class.new
end
