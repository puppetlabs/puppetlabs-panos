require 'spec_helper'
require 'support/matchers/have_xml'
require 'puppet/provider/panos_static_route_base'
require 'support/shared_examples'
require 'puppet/type/panos_ipv6_static_route'
require 'puppet/type/panos_static_route'
RSpec.describe Puppet::Provider::PanosStaticRouteBase do
  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Panos::Device', 'device') }
  let(:typedef) { instance_double('Puppet::ResourceApi::TypeDefinition', 'typedef') }
  let(:provider) { described_class.new('ip') }

  before(:each) do
    allow(context).to receive(:device).with(no_args).and_return(device)
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

  describe '#set(context, changes)' do
    context 'with no changes' do
      let(:changes) { {} }

      it 'does not call create' do
        expect(provider).to receive(:create).never
        provider.set(context, changes)
      end
      it 'does not call update' do
        expect(provider).to receive(:update).never
        provider.set(context, changes)
      end
      it 'does not call delete' do
        expect(provider).to receive(:delete).never
        provider.set(context, changes)
      end
    end

    context 'with a single change to create a resource' do
      let(:should_values) { { route: 'title', ensure: 'present' } }
      let(:changes) do
        { 'title' =>
          {
            should: should_values,
          } }
      end

      before(:each) do
        allow(provider).to receive(:get).and_return({})
        allow(typedef).to receive(:check_schema)
      end

      it 'calls create' do
        expect(context).to receive(:creating).with('title').and_yield
        expect(provider).to receive(:create).with(context, 'title', should_values).once
        provider.set(context, changes)
      end
    end

    context 'with a single change to update a resource' do
      let(:is_values) { { route: 'title', ensure: 'present' } }
      let(:should_values) { { route: 'title', ensure: 'present' } }
      let(:changes) do
        { 'title' =>
          {
            is: is_values,
            should: should_values,
          } }
      end

      it 'calls update' do
        expect(context).to receive(:updating).with('title').and_yield
        expect(provider).to receive(:update).with(context, 'title', should_values).once
        provider.set(context, changes)
      end
    end

    context 'with a single change to delete a resource' do
      let(:is_values) { { route: 'title', ensure: 'present', vr_name: 'vr_name' } }
      let(:should_values) { { route: 'title', ensure: 'absent', vr_name: 'vr_name' } }
      let(:changes) do
        { 'title' =>
          {
            is: is_values,
            should: should_values,
          } }
      end

      it 'calls delete once' do
        allow(context).to receive(:deleting).with('title').and_yield
        expect(provider).to receive(:delete).with(context, 'title', 'vr_name').once
        provider.set(context, changes)
      end
    end

    context 'with multiple changes' do
      let(:changes) do
        {
          'to create' =>
          {
            should: { route: 'to create', ensure: 'present' },
          },
          'to update' =>
          {
            is: { route: 'to update', ensure: 'present' },
            should: { route: 'to update', ensure: 'present' },
          },
          'to delete' =>
          {
            is: { route: 'to delete', ensure: 'present', vr_name: 'vr_name' },
            should: { route: 'to delete', ensure: 'absent', vr_name: 'vr_name' },
          },
        }
      end

      before(:each) do
        allow(typedef).to receive(:check_schema)
        allow(provider).to receive(:get).and_return({})
      end

      it 'calls the crud methods' do
        expect(context).to receive(:creating).with('to create').and_yield
        expect(provider).to receive(:create).with(context, 'to create', hash_including(route: 'to create'))

        allow(context).to receive(:updating).with('to update').and_yield
        expect(provider).to receive(:update).with(context, 'to update', hash_including(route: 'to update'))

        allow(context).to receive(:deleting).with('to delete').and_yield
        expect(provider).to receive(:delete).with(context, 'to delete', 'vr_name')

        provider.set(context, changes)
      end
    end

    context 'with a type that does not implement ensurable' do
      let(:is_values) { { route: 'title', content: 'foo' } }
      let(:should_values) { { route: 'title', content: 'bar' } }
      let(:changes) do
        { 'title' =>
              {
                is: is_values,
                should: should_values,
              } }
      end

      before(:each) do
        allow(context).to receive(:updating).with('title').and_yield
        allow(typedef).to receive(:ensurable?).and_return(false)
      end
      it { expect { provider.set(context, changes) }.to raise_error %r{PanosStaticRouteBase cannot be used with a Type that is not ensurable} }
    end
  end

  describe '#xml_from_should(_name, should)' do
    test_data = [
      {
        desc: 'a full example route',
        attrs: {
          route: 'test route 1',
          nexthop: '10.7.4.1',
          nexthop_type: 'ip-address',
          bfd_profile: 'newbfd',
          interface: 'vlan.1',
          metric: '10',
          admin_distance: '15',
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
        attrs: {
          nexthop_type: 'ipv6-address',
          nexthop: '2001:0dc8::/128',
          interface: 'ethernet1/8',
          bfd_profile: 'default',
          metric: '300',
          admin_distance: '10',
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
        attrs: {
          route: 'test route 2',
          nexthop_type: 'discard',
          bfd_profile: 'None',
          metric: '10',
          admin_distance: '15',
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
        attrs: {
          route: 'test route 3',
          nexthop: 'next vr',
          nexthop_type: 'next-vr',
          bfd_profile: 'None',
          metric: '10',
          admin_distance: '15',
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
        attrs: {
          route: 'test route 4',
          nexthop_type: 'none',
          bfd_profile: 'None',
          interface: 'vlan.1',
          metric: '10',
          admin_distance: '15',
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
          metric: '25',
          admin_distance: '15',
          destination: '10.9.0.1/32',
          no_install: false,
          vr_name: 'example VR',
          title: "example VR/example SR-example VR",
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

    it 'allows device api error to bubble up' do
      allow(device).to receive(:get_config).with('some_xpath/entry').and_raise(Puppet::ResourceError, 'Some Error Message')

      expect { provider.get(context) }.to raise_error Puppet::ResourceError
    end

    context 'ipv4 provider' do
      let(:ip_version) { 'ip' }
      let(:provider) { described_class.new(ip_version) }

      it 'processes resources' do
        allow(device).to receive(:get_config).with('some_xpath/entry').and_return(example_data)
        allow(typedef).to receive(:attributes).and_return(Puppet::Type.type(:panos_static_route).type_definition.attributes)

        expect(provider.get(context)).to eq resource_data
      end
    end
    context 'ipv6 provider' do
      let(:ip_version) { 'ipv6' }
      let(:attrs) {}
      let(:provider) { described_class.new(ip_version) }

      it 'processes resources' do
        allow(device).to receive(:get_config).with('some_xpath/entry').and_return(example_data)
        allow(typedef).to receive(:attributes).with(no_args).and_return(Puppet::Type.type(:panos_ipv6_static_route).type_definition.attributes)

        expect(provider.get(context)).to eq resource_data
      end
    end
  end

  describe '#create(context, _name, should)' do
    context 'when called' do
      let(:expected_path) do
        '/config/devices/entry/network/virtual-router/entry[@name=\'bar\']/routing-table/ip/static-route'
      end
      let(:should_values) do
        {
          name: 'foo',
          vr_name: 'bar',
        }
      end
      let(:mystruct) { {} }

      it 'will call set_config' do
        expect(typedef).to receive(:definition).and_return(mystruct).twice
        expect(provider).to receive(:validate_should).with(should_values)
        expect(provider).to receive(:xml_from_should).with('foo', should_values)
        expect(device).to receive(:set_config).with(expected_path, anything)
        provider.create(context, 'name', should_values)
      end
    end
  end

  describe '#update(context, name, should)' do
    context 'when called' do
      let(:expected_path) do
        '/config/devices/entry/network/virtual-router/entry[@name=\'bar\']/routing-table/ip/static-route'
      end
      let(:should_values) do
        {
          name: 'foo',
          vr_name: 'bar',
        }
      end
      let(:mystruct) { {} }

      it 'will call edit_config' do
        expect(typedef).to receive(:definition).and_return(mystruct).twice
        expect(provider).to receive(:validate_should).with(should_values)
        expect(provider).to receive(:xml_from_should).with('foo', should_values)
        expect(device).to receive(:set_config).with(expected_path, anything)
        provider.update(context, 'name', should_values)
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

      it 'will call delete_config' do
        expect(typedef).to receive(:definition).and_return(mystruct)
        expect(device).to receive(:delete_config).with(expected_path)
        provider.delete(context, 'name', 'bar')
      end
    end
  end
end
