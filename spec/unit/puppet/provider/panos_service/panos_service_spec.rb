require 'spec_helper'
require 'support/matchers/have_xml'

# TODO: needs some cleanup/helper to avoid this misery
module Puppet::Provider::PanosService; end
require 'puppet/provider/panos_service/panos_service'

RSpec.describe Puppet::Provider::PanosService::PanosService do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Panos::Device', 'device') }
  let(:typedef) { instance_double('Puppet::ResourceApi::TypeDefinition', 'typedef') }
  let(:example_data) do
    REXML::Document.new <<EOF
    <response status="success" code="19">
      <result total-count="1" count="1">
        <entry name="Comms">
          <protocol>
            <udp>
              <port>8888,8881,8882</port>
              <source-port>1234,3214,5432</source-port>
            </udp>
          </protocol>
          <tag>
            <member>foo</member>
          </tag>
          <description>Voice Chat</description>
        </entry>
        <entry name="ftp">
          <protocol>
            <tcp>
              <port>21</port>
            </tcp>
          </protocol>
          <tag>
            <member>foo</member>
            <member>bar</member>
          </tag>
          <description>ftp server</description>
        </entry>
        <entry name="Application">
          <protocol>
            <tcp>
              <port>3478-3479</port>
            </tcp>
          </protocol>
          <tag>
            <member>wibble</member>
          </tag>
          <description>Demo App</description>
        </entry>
      </result>
    </response>
EOF
  end
  let(:resource_data) do
    [
      {
        name: 'Comms',
        ensure: 'present',
        description: 'Voice Chat',
        protocol: 'udp',
        dest_port: '8888,8881,8882',
        src_port: '1234,3214,5432',
        tags: ['foo'],
      },
      {
        name: 'ftp',
        ensure: 'present',
        description: 'ftp server',
        protocol: 'tcp',
        dest_port: '21',
        src_port: nil,
        tags: ['foo', 'bar'],
      },
      {
        name: 'Application',
        ensure: 'present',
        description: 'Demo App',
        protocol: 'tcp',
        dest_port: '3478-3479',
        src_port: nil,
        tags: ['wibble'],
      },
    ]
  end

  before(:each) do
    allow(context).to receive(:device).with(no_args).and_return(device)
    allow(context).to receive(:type).with(no_args).and_return(typedef)
    allow(context).to receive(:notice)
    allow(typedef).to receive(:definition).with(no_args).and_return(base_xpath: 'some xpath')
  end

  describe '#get' do
    it 'processes resources' do
      allow(typedef).to receive(:attributes).with(no_args).and_return(name: { xpath: 'string(@name)' },
                                                                      ensure: {},
                                                                      description: { xpath: 'description/text()' },
                                                                      protocol: { xpath: 'local-name(protocol/*[1])' },
                                                                      dest_port: { xpath: 'protocol/*[1]/port/text()' },
                                                                      src_port: { xpath: 'protocol/*[1]/source-port/text()' },
                                                                      tags: { xpath_array: 'tag/member/text()' })
      allow(device).to receive(:get_config).with('some xpath/entry').and_return(example_data)

      expect(provider.get(context)).to eq resource_data
    end
  end

  describe 'create(context, name, should)' do
    before(:each) do
      allow(device).to receive(:set_config)
    end

    it 'logs the call' do
      expect(context).to receive(:notice).with(%r{\ACreating \'#{resource_data[0][:name]}\'})
      provider.create(context, resource_data[0][:name], resource_data[0])
    end

    it 'uses the correct base structure' do
      expect(device).to receive(:set_config).with('some xpath', instance_of(String)) do |_xpath, doc|
        expect(doc).to have_xml("entry[@name='#{resource_data[0][:name]}']")
      end
      provider.create(context, resource_data[0][:name], resource_data[0])
    end

    context 'when protocol is tcp' do
      it 'creates the resource' do
        expect(device).to receive(:set_config).with('some xpath', instance_of(String)) do |_xpath, doc|
          expect(doc).to have_xml('entry/protocol/tcp')
          expect(doc).to have_xml('entry/protocol/tcp/port', '8888,8881,8882')
          expect(doc).to have_xml('entry/protocol/tcp/source-port', '2222')
          expect(doc).not_to have_xml('entry/protocol/udp')
        end

        provider.create(context, 'service1', name: 'service1', ensure: 'present', description: 'example service', protocol: 'tcp',
                                             dest_port: '8888,8881,8882', src_port: '2222', tags: ['foo'])
      end
    end

    context 'when protocol is udp' do
      it 'creates the resource' do
        expect(device).to receive(:set_config).with('some xpath', instance_of(String)) do |_xpath, doc|
          expect(doc).to have_xml('entry/protocol/udp')
          expect(doc).to have_xml('entry/protocol/udp/port', '8888,8881,8882')
          expect(doc).to have_xml('entry/protocol/udp/source-port', '2222')
          expect(doc).not_to have_xml('entry/protocol/tcp')
        end

        provider.create(context, 'service1', name: 'service1', ensure: 'present', description: 'example service', protocol: 'udp',
                                             dest_port: '8888,8881,8882', src_port: '2222', tags: ['foo'])
      end
    end

    context 'when providing tags' do
      it 'creates the resource' do
        expect(device).to receive(:set_config).with('some xpath', instance_of(String)) do |_xpath, doc|
          expect(doc).to have_xml('entry/tag/member', 'tag1')
          expect(doc).to have_xml('entry/tag/member', 'tag2')
        end

        provider.create(context, 'service1', name: 'service1', ensure: 'present', description: 'example service', protocol: 'udp',
                                             dest_port: '8888,8881,8882', src_port: '2222', tags: ['tag1', 'tag2'])
      end
    end
  end

  describe 'update(context, name, should)' do
    before(:each) do
      allow(device).to receive(:edit_config)
    end

    it 'logs the call' do
      expect(context).to receive(:notice).with(%r{\AUpdating \'#{resource_data[0][:name]}\'})
      provider.update(context, resource_data[0][:name], resource_data[0])
    end

    it 'uses the correct base structure' do
      expect(device).to receive(:edit_config).with("some xpath/entry[@name=\'#{resource_data[0][:name]}\']", instance_of(String)) do |_xpath, doc|
        expect(doc).to have_xml("entry[@name=\'#{resource_data[0][:name]}\']")
      end
      provider.update(context, resource_data[0][:name], resource_data[0])
    end

    context 'when protocol is tcp' do
      it 'updates the resource' do
        expect(device).to receive(:edit_config).with('some xpath/entry[@name=\'service1\']', instance_of(String)) do |_xpath, doc|
          expect(doc).to have_xml('entry/protocol/tcp')
          expect(doc).to have_xml('entry/protocol/tcp/port', '8888,8881,8882')
          expect(doc).to have_xml('entry/protocol/tcp/source-port', '2222')
          expect(doc).not_to have_xml('entry/protocol/udp')
        end

        provider.update(context, 'service1', name: 'service1', ensure: 'present', description: 'example service', protocol: 'tcp',
                                             dest_port: '8888,8881,8882', src_port: '2222', tags: ['foo'])
      end
    end

    context 'when protocol is udp' do
      it 'updates the resource' do
        expect(device).to receive(:edit_config).with('some xpath/entry[@name=\'service1\']', instance_of(String)) do |_xpath, doc|
          expect(doc).to have_xml('entry/protocol/udp')
          expect(doc).to have_xml('entry/protocol/udp/port', '8888,8881,8882')
          expect(doc).to have_xml('entry/protocol/udp/source-port', '2222')
          expect(doc).not_to have_xml('entry/protocol/tcp')
        end

        provider.update(context, 'service1', name: 'service1', ensure: 'present', description: 'example service', protocol: 'udp',
                                             dest_port: '8888,8881,8882', src_port: '2222', tags: ['foo'])
      end
    end

    context 'when providing tags' do
      it 'updates the resource' do
        expect(device).to receive(:edit_config).with('some xpath/entry[@name=\'service1\']', instance_of(String)) do |_xpath, doc|
          expect(doc).to have_xml('entry/tag/member', 'tag1')
          expect(doc).to have_xml('entry/tag/member', 'tag2')
        end

        provider.update(context, 'service1', name: 'service1', ensure: 'present', description: 'example service', protocol: 'tcp',
                                             dest_port: '8888,8881,8882', src_port: '2222', tags: ['tag1', 'tag2'])
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
    context 'when src_port port is provided' do
      let(:should_hash) do
        {
          name: 'service1',
          ensure: 'present',
          description: 'example service',
          protocol: 'tcp',
          src_port: '2222',
          tags: ['tag1', 'tag2'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when is dest_port port is provided' do
      let(:should_hash) do
        {
          name: 'service1',
          ensure: 'present',
          description: 'example service',
          protocol: 'tcp',
          dest_port: '8888,8881,8882',
          tags: ['tag1', 'tag2'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when is dest_port and src_port port is provided' do
      let(:should_hash) do
        {
          name: 'service1',
          ensure: 'present',
          description: 'example service',
          protocol: 'tcp',
          dest_port: '8888,8881,8882',
          src_port: '2222',
          tags: ['tag1', 'tag2'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when neither src_port or dest_port port is provided' do
      let(:should_hash) do
        {
          name: 'service1',
          ensure: 'present',
          description: 'example service',
          protocol: 'tcp',
          tags: ['tag1', 'tag2'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{`src_port` or `dest_port` must be provided} }
    end
  end
end
