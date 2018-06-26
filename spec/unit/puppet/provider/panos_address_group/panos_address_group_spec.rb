require 'spec_helper'
require 'support/matchers/have_xml'

# TODO: needs some cleanup/helper to avoid this misery
module Puppet::Provider::PanosAddressGroup; end
require 'puppet/provider/panos_address_group/panos_address_group'

RSpec.describe Puppet::Provider::PanosAddressGroup::PanosAddressGroup do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Panos::Device', 'device') }
  let(:typedef) { instance_double('Puppet::ResourceApi::TypeDefinition', 'typedef') }
  let(:example_data) do
    REXML::Document.new <<EOF
    <response status="success" code="19">
      <result total-count="2" count="2">
        <entry oldname="demo_group-1" name="demo_group_dynamic">
          <tag>
            <member>foo</member>
            <member>bar</member>
          </tag>
          <description>dynamic test address group</description>
          <dynamic>
            <filter>'foo' or 'wibble' and 'bar' </filter>
          </dynamic>
        </entry>
        <entry name="demo_group">
          <description>static test address group</description>
          <static>
            <member>demo_group_dynamic</member>
          </static>
          <tag>
            <member>foo</member>
            <member>wibble</member>
          </tag>
        </entry>
      </result>
    </response>
EOF
  end

  before(:each) do
    allow(context).to receive(:device).with(no_args).and_return(device)
    allow(context).to receive(:type).with(no_args).and_return(typedef)
    allow(context).to receive(:notice)
    allow(typedef).to receive(:definition).with(no_args).and_return(base_xpath: 'some xpath')
  end

  describe '#get' do
    it 'processes resources' do
      allow(typedef).to receive(:attributes).with(no_args).and_return(description: { xpath: 'description/text()' },
                                                                      type: {},
                                                                      static_members: { xpath_array: 'static/member/text()' },
                                                                      dynamic_filter: { xpath: 'dynamic/filter/text()' },
                                                                      tags: { xpath_array: 'tag/member/text()' })
      allow(device).to receive(:get_config).with('some xpath/entry').and_return(example_data)

      expect(provider.get(context)).to eq [
        {
          name: 'demo_group_dynamic',
          ensure: 'present',
          description: 'dynamic test address group',
          type: 'dynamic',
          dynamic_filter: '\'foo\' or \'wibble\' and \'bar\' ',
          tags: ['foo', 'bar'],
        },
        {
          name: 'demo_group',
          ensure: 'present',
          description: 'static test address group',
          type: 'static',
          static_members: ['demo_group_dynamic'],
          tags: ['foo', 'wibble'],
        },
      ]
    end
  end

  describe 'create(context, name, should)' do
    before(:each) do
      allow(device).to receive(:set_config)
    end

    it 'logs the call' do
      expect(context).to receive(:notice).with(%r{\ACreating 'group_a'})
      provider.create(context, 'group_a', {})
    end

    it 'uses the correct base structure' do
      expect(device).to receive(:set_config).with('some xpath', instance_of(REXML::Document)) do |_xpath, doc|
        expect(doc).to have_xml("entry[@name='group_a']")
      end
      provider.create(context, 'group_a', {})
    end

    context 'when providing static_members' do
      it 'creates the resource' do
        expect(device).to receive(:set_config).with('some xpath', instance_of(REXML::Document)) do |_xpath, doc|
          expect(doc).to have_xml('entry/static/member', 'foo')
          expect(doc).to have_xml('entry/static/member', 'bar')
          expect(doc).not_to have_xml('entry/dynamic')
        end

        provider.create(context, 'group_a', name: 'group_a', ensure: 'present', description: 'test', type: 'static', static_members: ['foo', 'bar'], tags: [])
      end
    end

    context 'when providing dynamic filter' do
      it 'creates the resource' do
        expect(device).to receive(:set_config).with('some xpath', instance_of(REXML::Document)) do |_xpath, doc|
          expect(doc).to have_xml('entry/dynamic/filter', 'test filter')
          expect(doc).not_to have_xml('entry/static')
        end

        provider.create(context, 'group_a', name: 'group_a', ensure: 'present', description: 'test', type: 'dynamic', dynamic_filter: 'test filter', tags: [])
      end
    end

    context 'when providing tags' do
      it 'creates the resource' do
        expect(device).to receive(:set_config).with('some xpath', instance_of(REXML::Document)) do |_xpath, doc|
          expect(doc).to have_xml('entry/tag/member', 'tag1')
          expect(doc).to have_xml('entry/tag/member', 'tag2')
        end

        provider.create(context, 'group_a', name: 'group_a', ensure: 'present', description: 'test', type: 'dynamic', dynamic_filter: 'test filter', tags: ['tag1', 'tag2'])
      end
    end
  end

  describe 'update(context, name, should)' do
    before(:each) do
      allow(device).to receive(:edit_config)
    end

    it 'logs the call' do
      expect(context).to receive(:notice).with(%r{\AUpdating 'group_a'})
      provider.update(context, 'group_a', {})
    end

    it 'uses the correct base structure' do
      expect(device).to receive(:edit_config).with("some xpath/entry[@name='group_a']", instance_of(REXML::Document)) do |_xpath, doc|
        expect(doc).to have_xml("entry[@name='group_a']")
      end
      provider.update(context, 'group_a', {})
    end

    context 'when providing static_members' do
      it 'updates the resource' do
        expect(device).to receive(:edit_config).with('some xpath/entry[@name=\'group_a\']', instance_of(REXML::Document)) do |_xpath, doc|
          expect(doc).to have_xml('entry/static')
          expect(doc).to have_xml('entry/static/member', 'foo')
          expect(doc).to have_xml('entry/static/member', 'bar')
          expect(doc).not_to have_xml('entry/dynamic')
        end

        provider.update(context, 'group_a', name: 'group_a', ensure: 'present', description: 'test', type: 'static', static_members: ['foo', 'bar'], tags: [])
      end
    end

    context 'when providing dynamic filter' do
      it 'updates the resource' do
        expect(device).to receive(:edit_config).with('some xpath/entry[@name=\'group_a\']', instance_of(REXML::Document)) do |_xpath, doc|
          expect(doc).to have_xml('entry/dynamic/filter', 'test filter')
          expect(doc).not_to have_xml('entry/static')
        end

        provider.update(context, 'group_a', name: 'group_a', ensure: 'present', description: 'test', type: 'dynamic', dynamic_filter: 'test filter', tags: [])
      end
    end

    context 'when providing tags' do
      it 'updates the resource' do
        expect(device).to receive(:edit_config).with('some xpath/entry[@name=\'group_a\']', instance_of(REXML::Document)) do |_xpath, doc|
          expect(doc).to have_xml('entry/tag/member', 'tag1')
          expect(doc).to have_xml('entry/tag/member', 'tag2')
        end

        provider.update(context, 'group_a', name: 'group_a', ensure: 'present', description: 'test', type: 'dynamic', dynamic_filter: 'test filter', tags: ['tag1', 'tag2'])
      end
    end
  end

  describe 'delete(context, name, should)' do
    before(:each) do
      allow(device).to receive(:delete_config)
    end

    it 'logs the call' do
      expect(context).to receive(:notice).with(%r{\ADeleting 'foo'})
      provider.delete(context, 'foo')
    end

    it 'deletes the resource' do
      expect(device).to receive(:delete_config).with("some xpath/entry[@name='foo']")

      provider.delete(context, 'foo')
    end
  end

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
end
