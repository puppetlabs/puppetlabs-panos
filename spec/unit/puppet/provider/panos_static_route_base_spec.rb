# frozen_string_literal: true

require 'spec_helper'
require 'support/matchers/have_xml'
require 'puppet/provider/panos_static_route_base'
require 'support/shared_examples'
require 'puppet/type/panos_ipv6_static_route'
require 'puppet/type/panos_static_route'
RSpec.describe Puppet::Provider::PanosStaticRouteBase do
  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:transport) { instance_double('Puppet::ResourceApi::Transport::Panos', 'transport') }
  let(:typedef) { instance_double('Puppet::ResourceApi::TypeDefinition', 'typedef') }
  let(:provider) { described_class.new('ip') }

  before(:each) do
    allow(context).to receive(:transport).with(no_args).and_return(transport)
    allow(context).to receive(:type).with(no_args).and_return(typedef)
    allow(typedef).to receive(:ensurable?).and_return(true)
  end

  describe '#initialize(version_label)' do
    let(:instance) {  described_class.new(label) }

    context 'store the version label' do
      let(:label) { 'some_version' }

      it { expect(instance.instance_variable_get('@version_label')).to eq label }
    end
  end

  describe '#munge(entry)' do
    context 'when the static route is configured with a no install option' do
      let(:entry) do
        {
          route: 'test route',
          no_install: 'no-install',
          vr_name: 'test vr',
        }
      end

      it { expect(provider.munge(entry)[:no_install]).to be_truthy }
    end
    context 'when the static route is configured without a no install option' do
      let(:entry) do
        {
          route: 'test route',
          vr_name: 'test vr',
        }
      end

      it { expect(provider.munge(entry)[:no_install]).to be_falsey }
    end
    context 'when the static route is configured without nexthop' do
      let(:entry) do
        {
          route: 'test route',
          vr_name: 'test vr',
        }
      end

      it { expect(provider.munge(entry)[:nexthop_type]).to eq('none') }
    end
    context 'when the static route is configured with nexthop' do
      let(:entry) do
        {
          route: 'test route',
          nexthop_type: 'ip-address',
          vr_name: 'test vr',
        }
      end

      it { expect(provider.munge(entry)[:nexthop_type]).to eq('ip-address') }
    end
  end

  describe '#xml_from_should(name, should)' do
    test_data = [
      {
        desc: 'a full example route',
        name: {
          route:    'test route 1',
          vr_name:  'new router',
          title:    'new router/test route 1',
        },
        attrs: {
          route: 'test route 1',
          nexthop: '10.7.4.1',
          nexthop_type: 'ip-address',
          bfd_profile: 'newbfd',
          interface: 'vlan.1',
          metric: 10,
          admin_distance: 15,
          destination: '10.7.4.0/32',
          no_install: true,
          vr_name: 'new router',
        },
        xml: '<entry name="test route 1">
                <nexthop>
                  <ip-address>10.7.4.1</ip-address>
                </nexthop>
                <bfd>
                  <profile>newbfd</profile>
                </bfd>
                <interface>vlan.1</interface>
                <metric>10</metric>
                <admin-dist>15</admin-dist>
                <destination>10.7.4.0/32</destination>
                <option>
                  <no-install/>
                </option>
              </entry>',
      },
      {
        desc: 'a full ipv6 example route',
        name: {
          route:    'test route ipv6',
          vr_name:  'new router',
          title:    'new router/test route ipv6',
        },
        attrs: {
          nexthop_type: 'ipv6-address',
          nexthop: '2001:0dc8::/128',
          interface: 'ethernet1/8',
          bfd_profile: 'default',
          metric: 300,
          admin_distance: 10,
          destination: '2001::/16',
          no_install: false,
          vr_name: 'new router',
          route: 'test route ipv6',
        },
        xml: '<entry name="test route ipv6">
                <nexthop>
                  <ipv6-address>2001:0dc8::/128</ipv6-address>
                </nexthop>
                <bfd>
                  <profile>default</profile>
                </bfd>
                <interface>ethernet1/8</interface>
                <metric>300</metric>
                <admin-dist>10</admin-dist>
                <destination>2001::/16</destination>
              </entry>',
      },
      {
        desc: 'a route configured to discard.',
        name: {
          route:    'test route 2',
          vr_name:  'new router',
          title:    'new router/test route 2',
        },
        attrs: {
          route: 'test route 2',
          nexthop_type: 'discard',
          bfd_profile: 'None',
          metric: 10,
          admin_distance: 15,
          destination: '10.7.4.0/32',
          no_install: false,
          vr_name: 'new router',
        },
        xml: '<entry name="test route 2">
                <nexthop>
                  <discard/>
                </nexthop>
                <bfd>
                  <profile>None</profile>
                </bfd>
                <metric>10</metric>
                <admin-dist>15</admin-dist>
                <destination>10.7.4.0/32</destination>
              </entry>',
      },
      {
        desc: 'a route with a nexthop of another virtual router.',
        name: {
          route:    'test route 3',
          vr_name:  'new router',
          title:    'new router/test route 3',
        },
        attrs: {
          route: 'test route 3',
          nexthop: 'next vr',
          nexthop_type: 'next-vr',
          bfd_profile: 'None',
          metric: 10,
          admin_distance: 15,
          destination: '10.7.4.0/32',
          no_install: false,
          vr_name: 'new router',
        },
        xml: '<entry name="test route 3">
                <nexthop>
                  <next-vr>next vr</next-vr>
                </nexthop>
                <bfd>
                  <profile>None</profile>
                </bfd>
                <metric>10</metric>
                <admin-dist>15</admin-dist>
                <destination>10.7.4.0/32</destination>
              </entry>',
      },
      {
        desc: 'a route configured with no next hop.',
        name: {
          route:    'test route 4',
          vr_name:  'new router',
          title:    'new router/test route 4',
        },
        attrs: {
          route: 'test route 4',
          nexthop_type: 'none',
          bfd_profile: 'None',
          interface: 'vlan.1',
          metric: 10,
          admin_distance: 15,
          destination: '10.7.4.0/32',
          no_install: false,
          vr_name: 'new router',
        },
        xml: '<entry name="test route 4">
                <bfd>
                  <profile>None</profile>
                </bfd>
                <interface>vlan.1</interface>
                <metric>10</metric>
                <admin-dist>15</admin-dist>
                <destination>10.7.4.0/32</destination>
              </entry>',
      },
      {
        desc: 'a route configured with path monitoring.',
        name: {
          route:    'test route 4',
          vr_name:  'new router',
          title:    'new router/test route 4',
        },
        attrs: {
          route: 'test route 4',
          nexthop_type: 'none',
          bfd_profile: 'None',
          interface: 'vlan.1',
          metric: 10,
          admin_distance: 15,
          destination: '10.7.4.0/32',
          no_install: false,
          path_monitoring: true,
          enable: true,
          failure_condition: 'any',
          hold_time: 2,
          vr_name: 'new router',
        },
        xml: '<entry name="test route 4">
                <bfd>
                  <profile>None</profile>
                </bfd>
                <path-monitor>
                  <enable>yes</enable>
                  <failure-condition>any</failure-condition>
                  <hold-time>2</hold-time>
                </path-monitor>
                <interface>vlan.1</interface>
                <metric>10</metric>
                <admin-dist>15</admin-dist>
                <destination>10.7.4.0/32</destination>
              </entry>',
      },
      {
        desc: 'a route configured with path monitoring enabled set to false.',
        name: {
          route:    'test route 4',
          vr_name:  'new router',
          title:    'new router/test route 4',
        },
        attrs: {
          route: 'test route 4',
          nexthop_type: 'none',
          bfd_profile: 'None',
          interface: 'vlan.1',
          metric: 10,
          admin_distance: 15,
          destination: '10.7.4.0/32',
          no_install: false,
          path_monitoring: true,
          enable: false,
          failure_condition: 'any',
          hold_time: 2,
          vr_name: 'new router',
        },
        xml: '<entry name="test route 4">
                <bfd>
                  <profile>None</profile>
                </bfd>
                <path-monitor>
                  <failure-condition>any</failure-condition>
                  <hold-time>2</hold-time>
                </path-monitor>
                <interface>vlan.1</interface>
                <metric>10</metric>
                <admin-dist>15</admin-dist>
                <destination>10.7.4.0/32</destination>
              </entry>',
      },
      {
        desc: 'a route configured with path monitoring enabled set to false.',
        name: {
          route:    'test route 4',
          vr_name:  'new router',
          title:    'new router/test route 4',
        },
        attrs: {
          route: 'test route 4',
          nexthop_type: 'none',
          bfd_profile: 'None',
          interface: 'vlan.1',
          metric: 10,
          admin_distance: 15,
          destination: '10.7.4.0/32',
          no_install: false,
          path_monitoring: true,
          enable: false,
          failure_condition: 'any',
          hold_time: 2,
          route_type: 'unicast',
          vr_name: 'new router',
        },
        xml: '<entry name="test route 4">
                <bfd>
                  <profile>None</profile>
                </bfd>
                <path-monitor>
                  <failure-condition>any</failure-condition>
                  <hold-time>2</hold-time>
                </path-monitor>
                <interface>vlan.1</interface>
                <metric>10</metric>
                <admin-dist>15</admin-dist>
                <destination>10.7.4.0/32</destination>
                <route-table>
                  <unicast/>
                </route-table>
              </entry>',
      },
    ]

    include_examples 'xml_from_should(name, should)', test_data, described_class.new('ip')
  end

  describe '#validate_should' do
    context 'when no interface is provided and the nexthop type isnt discard' do
      let(:entry) do
        {
          route: 'test route',
          nexthop_type: 'ip-address',
          interface: nil,
          vr_name: 'test vr',
          destination: '10.8.3.1',
        }
      end

      it { expect { provider.validate_should(entry) }.to raise_error Puppet::ResourceError, %r{Interfaces must be provided if no Next Hop or Virtual Router is specified for next hop} }
    end

    context 'when no interface is provided and the nexthop type is discard' do
      let(:entry) do
        {
          route: 'test route',
          nexthop_type: 'discard',
          interface: nil,
          bfd_profile: 'None',
          vr_name: 'test vr',
        }
      end

      it { expect { provider.validate_should(entry) }.not_to raise_error }
    end

    context 'when the static route uses a BFD profile, and is not configured to use a nexthop ip' do
      let(:entry) do
        {
          route: 'test route',
          nexthop_type: 'discard',
          bfd_profile: 'test bfd profile',
          vr_name: 'test vr',
        }
      end

      it { expect { provider.validate_should(entry) }.to raise_error Puppet::ResourceError, %r{BFD requires a nexthop_type to be `ip-address`} }
    end

    context 'when the static route uses a BFD profile, and is configured to use a nexthop ip-address' do
      let(:entry) do
        {
          route: 'test route',
          nexthop_type: 'ip-address',
          interface: 'test interface',
          bfd_profile: 'test bfd profile',
          vr_name: 'test vr',
        }
      end

      it { expect { provider.validate_should(entry) }.not_to raise_error }
    end

    context 'when the static route uses a BFD profile, and is configured to use a nexthop ipv6-address' do
      let(:entry) do
        {
          route: 'test route',
          nexthop_type: 'ipv6-address',
          interface: 'test interface',
          bfd_profile: 'test bfd profile',
          vr_name: 'test vr',
        }
      end

      it { expect { provider.validate_should(entry) }.not_to raise_error }
    end
  end

  describe '#get(context)' do
    let(:example_data) do
      REXML::Document.new <<EOF
        <response>
          <result>
            #{expected_xml}
          </result>
        </response>
EOF
    end

    let(:resource_data) do
      [
        {
          route: 'example SR-example VR',
          ensure: 'present',
          nexthop: '',
          nexthop_type: 'discard',
          bfd_profile: 'None',
          interface: nil,
          metric: 25,
          admin_distance: 15,
          destination: '10.9.0.1/32',
          no_install: false,
          vr_name: 'example VR',
          enable: false,
          failure_condition: nil,
          hold_time: nil,
          path_monitoring: false,
          route_type: nil,
          title: 'example VR/example SR-example VR',
        },
      ]
    end

    let(:expected_xml) do
      String.new <<EOF
        <entry name="example VR">
          <admin-dists>
            <static>20</static>
            <static-ipv6>20</static-ipv6>
            <ospf-int>20</ospf-int>
            <ospf-ext>20</ospf-ext>
            <ospfv3-int>20</ospfv3-int>
            <ospfv3-ext>20</ospfv3-ext>
            <ibgp>20</ibgp>
            <ebgp>20</ebgp>
            <rip>20</rip>
          </admin-dists>
          <routing-table>
            <#{ip_version}>
              <static-route>
                <entry name="example SR-example VR">
                  <nexthop>
                    <discard/>
                  </nexthop>
                  <bfd>
                    <profile>None</profile>
                  </bfd>
                  <metric>25</metric>
                  <admin-dist>15</admin-dist>
                  <destination>10.9.0.1/32</destination>
                </entry>
              </static-route>
            </#{ip_version}>
          </routing-table>
        </entry>
EOF
    end

    before(:each) do
      allow(typedef).to receive(:definition).and_return(base_xpath: 'some_xpath')
    end

    it 'allows transport api error to bubble up' do
      allow(transport).to receive(:get_config).with('some_xpath/entry').and_raise(Puppet::ResourceError, 'Some Error Message')

      expect { provider.get(context) }.to raise_error Puppet::ResourceError
    end

    context 'ipv4 provider' do
      let(:ip_version) { 'ip' }
      let(:provider) { described_class.new(ip_version) }

      it 'processes resources' do
        allow(transport).to receive(:get_config).with('some_xpath/entry').and_return(example_data)
        allow(typedef).to receive(:attributes).and_return(Puppet::Type.type(:panos_static_route).type_definition.attributes)

        expect(provider.get(context)).to eq resource_data
      end
    end
    context 'ipv6 provider' do
      let(:ip_version) { 'ipv6' }
      let(:attrs) {}
      let(:provider) { described_class.new(ip_version) }

      it 'processes resources' do
        allow(transport).to receive(:get_config).with('some_xpath/entry').and_return(example_data)
        allow(typedef).to receive(:attributes).with(no_args).and_return(Puppet::Type.type(:panos_ipv6_static_route).type_definition.attributes)

        expect(provider.get(context)).to eq resource_data
      end
    end
  end

  describe '#create(context, name, should)' do
    context 'when called' do
      let(:expected_path) do
        '/config/devices/entry/network/virtual-router/entry[@name=\'bar\']/routing-table/ip/static-route'
      end
      let(:namevars) do
        {
          vr_name: 'bar',
          route:   'foo',
          title:   'bar/foo',
        }
      end
      let(:mystruct) { {} }

      it 'will call set_config' do
        expect(typedef).to receive(:definition).and_return(mystruct).twice
        expect(provider).to receive(:validate_should).with(anything)
        expect(provider).to receive(:xml_from_should).with(namevars, anything)
        expect(transport).to receive(:set_config).with(expected_path, anything)
        provider.create(context, namevars, anything)
      end
    end
  end

  describe '#update(context, name, should)' do
    context 'when called' do
      let(:expected_path) do
        '/config/devices/entry/network/virtual-router/entry[@name=\'bar\']/routing-table/ip/static-route'
      end
      let(:namevars) do
        {
          vr_name: 'bar',
          route:   'foo',
          title:   'bar/foo',
        }
      end
      let(:mystruct) { {} }

      it 'will call edit_config' do
        expect(typedef).to receive(:definition).and_return(mystruct).twice
        expect(provider).to receive(:validate_should).with(anything)
        expect(provider).to receive(:xml_from_should).with(namevars, anything)
        expect(transport).to receive(:set_config).with(expected_path, anything)
        provider.update(context, namevars, anything)
      end
    end
  end

  describe '#delete(context, name, vr_name)' do
    context 'when called' do
      let(:expected_path) do
        '/some_xpath/entry[@name=\'bar\']/routing-table/ip/static-route/entry[@name=\'name\']'
      end
      let(:mystruct) do
        {
          base_xpath: '/some_xpath',
        }
      end
      let(:namevars) do
        {
          vr_name: 'bar',
          route:   'name',
          title:   'bar/name',
        }
      end

      it 'will call delete_config' do
        expect(typedef).to receive(:definition).and_return(mystruct)
        expect(transport).to receive(:delete_config).with(expected_path)
        provider.delete(context, namevars)
      end
    end
  end

  describe '#canonicalize(_context, resources' do
    context 'when resource values are passed as strings' do
      let(:resources) do
        [{
          hold_time: '15',
          metric: '5',
          admin_distance: '25',
        }]
      end
      let(:canonicalized_resources) do
        [{
          hold_time: 15,
          metric: 5,
          admin_distance: 25,
        }]
      end

      it 'converts them to integers' do
        expect(provider.canonicalize(context, resources)).to eq(canonicalized_resources)
      end
    end
    context 'when resource values are passed as nil' do
      let(:resources) do
        [{
          hold_time: nil,
          metric: nil,
          admin_distance: nil,
        }]
      end
      let(:canonicalized_resources) do
        [{
          hold_time: nil,
          metric: nil,
          admin_distance: nil,
        }]
      end

      it 'does nothing' do
        expect(provider.canonicalize(context, resources)).to eq(canonicalized_resources)
      end
    end
    context 'when resource values are passed as integers' do
      let(:resources) do
        [{
          hold_time: 2,
          metric: 500,
          admin_distance: 1000,
        }]
      end
      let(:canonicalized_resources) do
        [{
          hold_time: 2,
          metric: 500,
          admin_distance: 1000,
        }]
      end

      it 'does nothing' do
        expect(provider.canonicalize(context, resources)).to eq(canonicalized_resources)
      end
    end
  end
end
