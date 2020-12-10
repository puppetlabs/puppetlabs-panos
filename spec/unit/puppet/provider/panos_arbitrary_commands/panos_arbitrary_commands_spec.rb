# frozen_string_literal: true

require 'spec_helper'
require 'support/shared_examples'

module Puppet::Provider::PanosArbitraryCommands; end
require 'puppet/provider/panos_arbitrary_commands/panos_arbitrary_commands'

RSpec.describe Puppet::Provider::PanosArbitraryCommands::PanosArbitraryCommands do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:transport) { instance_double('Puppet::ResourceApi::Transport::Panos', 'transport') }
  let(:typedef) { instance_double('Puppet::ResourceApi::TypeDefinition', 'typedef') }

  let(:example_data) do
    REXML::Document.new <<EOF
      <response>
        <result>
          #{test_entry_1}
        </result>
      </response>
EOF
  end
  let(:test_entry_1) do
    String.new <<EOF
    <entry name="foo">
      <indent>bar</indent>
      <foo>
        <bar/>
      </foo>
    </entry>
EOF
  end

  let(:parsed_xml) { '<entry name="foo"><indent>bar</indent><foo><bar/></foo></entry>' }

  let(:resource_data) do
    [
      {
        xpath:  'foo',
        xml:    parsed_xml,
        ensure: 'present',
      },
    ]
  end
  let(:multiple_resource_data) do
    [
      {
        xpath:  'foo',
        xml:    parsed_xml,
        ensure: 'present',
      },
      {
        xpath:  'bar',
        xml:    parsed_xml,
        ensure: 'present',
      },
    ]
  end

  let(:error_resource_data) do
    [
      {
        xpath:  'foo',
        xml:    '<entry><foo></entry>',
        ensure: 'present',
      },
    ]
  end

  before(:each) do
    allow(context).to receive(:transport).with(no_args).and_return(transport)
  end

  describe '#canonicalize' do
    context 'when `canonicalize` is called with one resource' do
      it 'calls the `str_from_xml` once' do
        expect(provider).to receive(:str_from_xml).once # rubocop:disable RSpec/SubjectStub

        expect(provider.canonicalize(context, resource_data)).to eq(resource_data)
      end
    end
    context 'when `canonicalize` is called with more than one resource' do
      it 'calls the `str_from_xml` enough times' do
        expect(provider).to receive(:str_from_xml).twice # rubocop:disable RSpec/SubjectStub

        expect(provider.canonicalize(context, multiple_resource_data)).to eq(multiple_resource_data)
      end
    end
  end

  describe '#get' do
    context 'when `names` is nil' do
      it 'returns empty array' do
        expect(provider.get(context, nil)).to eq([])
      end
    end
    context 'when `names` is not nil' do
      it 'returns resource' do
        allow(transport).to receive(:get_config).with('/config/foo').and_return(example_data)
        allow(provider).to receive(:str_from_xml).and_return(parsed_xml) # rubocop:disable RSpec/SubjectStub

        expect(provider.get(context, ['foo'])).to eq(resource_data)
      end
    end
    context 'when transport issues an error' do
      it 'allows for transport errors to bubble up' do
        allow(transport).to receive(:get_config).with('/config/some').and_raise(Puppet::ResourceError, 'Some Error Message')

        expect { provider.get(context, ['some']) }.to raise_error Puppet::ResourceError
      end
    end
  end

  describe '#create' do
    context 'when xml is valid' do
      it 'does not produce an error' do
        allow(REXML::Document).to receive(:new).with(parsed_xml).and_return(example_data)
        allow(transport).to receive(:set_config).with('/config/foo', example_data)

        expect { provider.create(context, 'foo', resource_data[0]) }.not_to raise_error
      end
    end
    context 'when xml is invalid' do
      it 'produces an error' do
        allow(REXML::Document).to receive(:new).with('<entry><foo></entry>').and_raise(REXML::ParseException.new('Missing end tag for "foo" (got "entry")'))

        expect { provider.create(context, 'foo', error_resource_data[0]) }.to raise_error(Puppet::ResourceError, 'Missing end tag for "foo" (got "entry")')
      end
    end
  end

  describe '#update' do
    context 'when xml is valid' do
      it 'does not produce an error' do
        allow(REXML::Document).to receive(:new).with(parsed_xml).and_return(example_data)
        allow(transport).to receive(:edit_config).with('/config/foo', example_data)

        expect { provider.update(context, 'foo', resource_data[0]) }.not_to raise_error
      end
    end
    context 'when xml is invalid' do
      it 'produces an error' do
        allow(REXML::Document).to receive(:new).with('<entry><foo></entry>').and_raise(REXML::ParseException.new('Missing end tag for "foo" (got "entry")'))

        expect { provider.update(context, 'foo', error_resource_data[0]) }.to raise_error(Puppet::ResourceError, 'Missing end tag for "foo" (got "entry")')
      end
    end
  end

  describe '#delete' do
    it 'calls provider functions' do
      expect(transport).to receive(:delete_config).with('/config/foo')

      provider.delete(context, resource_data[0][:xpath])
    end
  end

  test_data_for_str_from_xml = [
    {
      desc:       'an example with `result` tags',
      raw_xml:    '<result total-count=\'10\'><entry></entry></result>',
      parsed_xml: '<entry></entry>',
    },
    {
      desc:       'an example with `admin` attributes',
      raw_xml:    '<entry admin=\'foo\'><indented admin=\'bar\'></indented></entry>',
      parsed_xml: '<entry><indented></indented></entry>',
    },
    {
      desc:       'an example with `time` attributes',
      raw_xml:    '<entry time=\'2014/12/23 12:00:00\'><indented time=\'2014/12/23 12:00:00\'></indented></entry>',
      parsed_xml: '<entry><indented></indented></entry>',
    },
    {
      desc:       'an example with `dirtyId` attributes',
      raw_xml:    '<entry dirtyId=\'203\'><indented dirtyId=\'203\'></indented></entry>',
      parsed_xml: '<entry><indented></indented></entry>',
    },
    {
      desc:       'an example with `name` attributes',
      raw_xml:    '<entry name=\'foo\'></entry>',
      parsed_xml: '<entry name="foo"></entry>',
    },
    {
      desc:       'an example with more than one space',
      raw_xml:    '<entry   name=\'foo\'></entry>',
      parsed_xml: '<entry name="foo"></entry>',
    },
    {
      desc:       'an example with spaces before the closing tags `>`',
      raw_xml:    '<entry   name=\'foo\'   ></entry   >',
      parsed_xml: '<entry name="foo"></entry>',
    },
    {
      desc:       'an example with spaces before the self-closing tags `/>`',
      raw_xml:    '<entry   name=\'foo\'   ><bar    /></entry   >',
      parsed_xml: '<entry name="foo"><bar/></entry>',
    },
    {
      desc:       'an example with new lines',
      raw_xml:    '<entry name=\'foo\'>
                  </entry>',
      parsed_xml: '<entry name="foo"></entry>',
    },
    {
      desc:       'an example with tabs',
      raw_xml:    '<entry name=\'foo\'>
                    <indent>bar</indent>
                    <foo>
                      <bar/>
                    </foo>
                  </entry>',
      parsed_xml: '<entry name="foo"><indent>bar</indent><foo><bar/></foo></entry>',
    },
  ]

  include_examples 'str_from_xml(xml)', test_data_for_str_from_xml, described_class.new
end
