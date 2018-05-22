require 'spec_helper'
require 'puppet/util/network_device/panos/device'

# TODO: needs some cleanup/helper to avoid this misery
module Puppet::Provider::PanosExample; end
require 'puppet/provider/panos_example/panos_example'

RSpec.describe Puppet::Provider::PanosExample::PanosExample do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Panos::Device', 'device') }

  before(:each) do
    allow(context).to receive(:device).with(no_args).and_return(device)
  end

  describe '#get' do
    it 'processes resources' do
      expect(device).to receive(:get_config).with("/config/devices/entry/vsys/entry[@name='vsys1']").and_return('some_xml')
      expect(provider.get(context)).to eq 'some_xml'
    end
  end

  describe 'create(context, name, should)' do
    it 'creates the resource' do
      expect(context).to receive(:notice).with(%r{\ACreating 'a'})
      expect(device).to receive(:set_config).with("/config/devices/entry/vsys/entry[@name='vsys1']/address[@id='a']", name: 'a', ensure: 'present')

      provider.create(context, 'a', name: 'a', ensure: 'present')
    end
  end

  describe 'update(context, name, should)' do
    it 'updates the resource' do
      expect(context).to receive(:notice).with(%r{\AUpdating 'foo'})
      expect(device).to receive(:set_config).with("/config/devices/entry/vsys/entry[@name='vsys1']/address[@id='foo']", name: 'foo', ensure: 'present')

      provider.update(context, 'foo', name: 'foo', ensure: 'present')
    end
  end

  describe 'delete(context, name, should)' do
    it 'deletes the resource' do
      expect(context).to receive(:notice).with(%r{\ADeleting 'foo'})
      expect(device).to receive(:delete_config).with("/config/devices/entry/vsys/entry[@name='vsys1']/address[@id='foo']")

      provider.delete(context, 'foo')
    end
  end
end
