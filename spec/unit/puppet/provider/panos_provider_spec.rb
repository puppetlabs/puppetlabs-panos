require 'spec_helper'
require 'support/matchers/have_xml'
require 'puppet/provider/panos_provider'

RSpec.describe Puppet::Provider::PanosProvider do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Panos::Device', 'device') }
  let(:typedef) { instance_double('Puppet::ResourceApi::TypeDefinition', 'typedef') }

  let(:attrs) do
    {
      name:        {
        type:      'String',
        xpath:      'string(@name)',
      },
      description:    {
        type:      'Optional[String]',
        xpath:     'description/text()',
      },
      is_enabled:    {
        type:      'Boolean',
        xpath:     'isenabled/text()',
      },
      maybe_enabled:    {
        type:      'Optional[Boolean]',
        xpath:     'enabled/text()',
      },
      tags:    {
        type:      'Array[String]',
        xpath_array:     'tag/member/text()',
      },
    }
  end

  let(:example_data) do
    REXML::Document.new <<EOF
      <response>
        <result>
          #{test_entry_1}
          #{test_entry_2}
        </result>
      </response>
EOF
  end
  let(:test_entry_1) do
    String.new <<EOF
    <entry name="value1">
      <isenabled>Yes</isenabled>
      <enabled>No</enabled>
      <description>&lt;eas&amp;lt;yxss/&gt;</description>
      <tag>
        <member>one</member>
        <member>two</member>
        <member>three</member>
      </tag>
    </entry>
EOF
  end
  let(:test_entry_2) do
    String.new <<EOF
    <entry name="value2">
      <isenabled>No</isenabled>
      <enabled>Yes</enabled>
      <description>desc test 2</description>
      <tag></tag>
    </entry>
EOF
  end

  let(:resource_data) do
    [
      {
        name: 'value1',
        description: '<eas&lt;yxss/>',
        is_enabled: 'Yes',
        maybe_enabled: 'No',
        tags: ['one', 'two', 'three'],
      },
      {
        name: 'value2',
        description: 'desc test 2',
        is_enabled: 'No',
        maybe_enabled: 'Yes',
        tags: [],
      },
    ]
  end

  before(:each) do
    allow(context).to receive(:device).with(no_args).and_return(device)
    allow(context).to receive(:type).with(no_args).and_return(typedef)
    allow(context).to receive(:notice)
    allow(typedef).to receive(:definition).with(no_args).and_return(base_xpath: 'some xpath')

    allow(provider).to receive(:validate_should) # rubocop:disable RSpec/SubjectStub
    allow(provider).to receive(:xml_from_should).and_return(test_entry_1) # rubocop:disable RSpec/SubjectStub
  end

  describe '#get' do
    it 'processes resources' do
      allow(typedef).to receive(:attributes).with(no_args).and_return(attrs)
      allow(device).to receive(:get_config).with('some xpath/entry').and_return(example_data)

      expect(provider.get(context)).to eq resource_data
    end
    it 'allows device api error to bubble up' do
      allow(typedef).to receive(:attributes).with(no_args).and_return(attrs)
      allow(device).to receive(:get_config).with('some xpath/entry').and_raise(Puppet::ResourceError, 'Some Error Message')

      expect { provider.get(context) }.to raise_error Puppet::ResourceError
    end
  end

  describe 'match(entry, attr)' do
    let(:attr) { { type: 'String' } }
    let(:attr_name) { :name }

    context 'when attr_name is :ensure' do
      let(:attr_name) { :ensure }

      it { expect(provider.match(test_entry_1, attr, attr_name)).to eq 'present' }
    end
    context 'when attr_name is not :ensure' do
      context 'when attr contains :xpath' do
        let(:attr) { { type: 'String', xpath: 'isenabled/text()' } }

        it do
          expect(provider).to receive(:text_match) # rubocop:disable RSpec/SubjectStub
          provider.match(test_entry_1, attr, attr_name)
        end
      end
      context 'when attr contains :xpath_array' do
        let(:attr) { { type: 'Array[String]]', xpath_array: 'tag/member/text()' } }
        let(:attr_name) { :tags }

        it do
          expect(provider).to receive(:array_match) # rubocop:disable RSpec/SubjectStub
          provider.match(test_entry_1, attr, attr_name)
        end
      end
    end
  end

  describe 'convert_bool(value)' do
    context 'when the value is `yes`' do
      it { expect(provider.convert_bool('yes')).to be_truthy }
    end
    context 'when the value is `no`' do
      it { expect(provider.convert_bool('no')).to be_falsey }
    end
    context 'when the value is nil' do
      it { expect(provider.convert_bool(nil)).to be_falsey }
    end
    context 'when the value is anything else' do
      it 'returns the value passed in' do
        expect(provider.convert_bool('foo')).to eq('foo')
      end
    end
  end

  describe 'build_tags(builder, should)' do
    let(:builder) { Builder::XmlMarkup.new }

    context 'if should contains :tags' do
      let(:attrs) do
        {
          name: 'build_tags',
          description: 'desc test',
          is_enabled: 'Yes',
          maybe_enabled: 'No',
          tags: ['one', 'two'],
        }
      end
      let(:xml) { '<tag><member>one</member><member>two</member></tag>' }

      it 'will return builder content with correct XML' do
        expect(provider.build_tags(builder, attrs)).to eq(xml)
      end
    end
    context 'if :tags is empty' do
      let(:attrs) do
        {
          name: 'build_tags',
          description: 'desc test',
          is_enabled: 'Yes',
          maybe_enabled: 'No',
          tags: [],
        }
      end
      let(:xml) { '<tag></tag>' }

      it 'will return builder content with correct XML' do
        expect(provider.build_tags(builder, attrs)).to eq(xml)
      end
    end
  end

  describe 'create(context, name, should)' do
    it 'calls provider functions' do
      expect(device).to receive(:set_config).with('some xpath', instance_of(String)) do |_xpath, doc|
        expect(doc).to have_xml('entry/description', '&lt;eas&amp;lt;yxss/&gt;')
        expect(doc).to have_xml('entry/isenabled', 'Yes')
        expect(doc).to have_xml('entry/enabled', 'No')
        expect(doc).to have_xml('entry/tag/member', 'one')
        expect(doc).to have_xml('entry/tag/member', 'two')
        expect(doc).to have_xml('entry/tag/member', 'three')
      end

      provider.create(context, resource_data[0][:name], resource_data[0])
    end
  end

  describe 'update(context, name, should)' do
    it 'calls provider functions' do
      expect(device).to receive(:edit_config).with('some xpath/entry[@name=\'value1\']', instance_of(String)) do |_xpath, doc|
        expect(doc).to have_xml('entry/description', '&lt;eas&amp;lt;yxss/&gt;')
        expect(doc).to have_xml('entry/isenabled', 'Yes')
        expect(doc).to have_xml('entry/enabled', 'No')
        expect(doc).to have_xml('entry/tag/member', 'one')
        expect(doc).to have_xml('entry/tag/member', 'two')
        expect(doc).to have_xml('entry/tag/member', 'three')
      end

      provider.update(context, resource_data[0][:name], resource_data[0])
    end
  end

  describe 'delete(context, name)' do
    it 'calls provider functions' do
      expect(device).to receive(:delete_config).with('some xpath/entry[@name=\'value1\']')

      provider.delete(context, resource_data[0][:name])
    end
  end
end
