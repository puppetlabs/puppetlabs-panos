require 'spec_helper'
require 'puppet/util/network_device/panos/device'

RSpec.describe 'the panos device' do
  let(:device) { Puppet::Util::NetworkDevice::Panos::Device.new('file:///') }
  let(:xml_doc) { REXML::Document.new(device_hash) }
  let(:device_hash) do
    '<response status="success">
      <result>
        <sw-version>7.1.0</sw-version>
        <multi-vsys>off</multi-vsys>
        <model>PA-VM</model>
      </result>
    </response>'
  end

  it 'parses facts correctly' do
    expect(device.parse_device_facts(xml_doc)).to eq('operatingsystem' => 'PA-VM', 'operatingsystemrelease' => '7.1.0', 'multi-vsys' => 'off')
  end
end
