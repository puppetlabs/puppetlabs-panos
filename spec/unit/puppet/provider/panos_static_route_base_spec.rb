require 'spec_helper'
require 'support/matchers/have_xml'
require 'puppet/provider/panos_static_route_base'

# rubocop:disable RSpec/MultipleDescribes
RSpec.describe Puppet::Provider::PanosStaticRouteBase do
  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:type_def) { instance_double('Puppet::ResourceApi::TypeDefinition', 'type_def') }
  let(:provider_class) do
    Class.new(described_class) do
      def get(context, _names = nil); end

      def create(context, _name, _should); end

      def update(context, _name, _should); end

      def delete(context, _name, vr_name); end
    end
  end
  let(:provider) { provider_class.new }

  before(:each) do
    allow(context).to receive(:type).and_return(type_def)
    allow(type_def).to receive(:ensurable?).and_return(true)
  end
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
      allow(context).to receive(:creating).with('title').and_yield
      allow(context).to receive(:type).and_return(type_def)
      allow(type_def).to receive(:feature?).with('simple_get_filter')
      allow(type_def).to receive(:check_schema)
    end
    it 'calls create once' do
      expect(provider).to receive(:create).with(context, 'title', should_values).once
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

    before(:each) do
      allow(context).to receive(:updating).with('title').and_yield
      allow(context).to receive(:type).and_return(type_def)
      allow(type_def).to receive(:feature?).with('simple_get_filter')
    end
    it 'does not call create' do
      expect(provider).to receive(:create).never
      provider.set(context, changes)
    end
    it 'calls update once' do
      expect(provider).to receive(:update).with(context, 'title', should_values).once
      provider.set(context, changes)
    end
    it 'does not call delete' do
      expect(provider).to receive(:delete).never
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

    before(:each) do
      allow(context).to receive(:deleting).with('title').and_yield
      allow(context).to receive(:type).and_return(type_def)
      allow(type_def).to receive(:feature?).with('simple_get_filter')
    end
    it 'does not call create' do
      expect(provider).to receive(:create).never
      provider.set(context, changes)
    end
    it 'does not call update' do
      expect(provider).to receive(:update).never
      provider.set(context, changes)
    end
    it 'calls delete once' do
      expect(provider).to receive(:delete).with(context, 'title', 'vr_name').once
      provider.set(context, changes)
    end
  end
  context 'with multiple changes' do
    let(:changes) do
      { 'to create' =>
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
        } }
    end

    before(:each) do
      allow(context).to receive(:creating).with('to create').and_yield
      allow(context).to receive(:updating).with('to update').and_yield
      allow(context).to receive(:deleting).with('to delete').and_yield
      allow(type_def).to receive(:feature?).with('simple_get_filter').exactly(3).times
    end
    it 'calls the crud methods' do
      expect(provider).to receive(:create).with(context, 'to create', hash_including(route: 'to create'))
      expect(provider).to receive(:update).with(context, 'to update', hash_including(route: 'to update'))
      expect(provider).to receive(:delete).with(context, 'to delete', 'vr_name')
      expect(type_def).to receive(:check_schema)
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
      allow(type_def).to receive(:feature?).with('simple_get_filter')
      allow(type_def).to receive(:ensurable?).and_return(false)
    end
    it { expect { provider.set(context, changes) }.to raise_error %r{SimpleProvider cannot be used with a Type that is not ensurable} }
  end
end

RSpec.describe Puppet::Provider::PanosStaticRouteBase do
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Panos::Device', 'device') }
  let(:typedef) { instance_double('Puppet::ResourceApi::TypeDefinition', 'typedef') }
  let(:provider) { described_class.new }
  let(:context) do
    @type =
      '<Puppet::ResourceApi::TypeDefinition:0x00007fc3323e1c80'
    @definition =
      { name: 'panos_static_route' }
  end
  let(:attrs) do
    {
      route: {
        type:       'Pattern[/^[a-zA-z0-9\-_\s\.]*$/]',
        xpath:      'string(@name)',
        behaviour:  :namevar,
      },
      ensure: {
        type:       'Enum[present, absent]',
        default:    'present',
      },
      nexthop: {
        type:      'Optional[String]',
        xpath:     'string(nexthop/*)',
      },
      nexthop_type: {
        type:      'Optional[Enum["ip-address", "next-vr", "discard", "None"]]',
        xpath:     'local-name(nexthop/*)',
      },
      bfd_profile: {
        type:      'Optional[String]',
        xpath:     'bfd/profile/text()',
      },
      interface: {
        type:      'Optional[String]',
        xpath:     'interface/text()',
      },
      metric: {
        type:      'Optional[String]',
        xpath:     'metric/text()',
      },
      admin_distance: {
        type:      'Optional[String]',
        xpath:     'admin-dist/text()',
      },
      destination: {
        type:      'String',
        xpath:     'destination/text()',
      },
      no_install: {
        type:       'Optional[Boolean]',
        xpath:      'local-name(option/no-install)',
      },
      vr_name: {
        type:       'String',
        behaviour:  :namevar,
      },
    }
  end
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
          <ip>
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
          </ip>
        </routing-table>
      </entry>
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
        no_install: nil,
        vr_name: 'example VR',
      },
    ]
  end

  before(:each) do
    allow(context).to receive(:device).with(no_args).and_return(device)
    allow(context).to receive(:type).with(no_args).and_return(typedef)
    allow(context).to receive(:notice)
    allow(typedef).to receive(:definition).with(no_args).and_return(base_xpath: 'some xpath')

    allow(provider).to receive(:validate_should)
    allow(provider).to receive(:xml_from_should).and_return(test_entry_1)
  end

  describe 'get(context)' do
    it 'processes resources -- For Ipv4 Static Routes' do
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
  describe 'create(context, name, should)' do
    it 'calls provider functions -- For Ipv4 Static Routes' do
      allow(typedef).to receive(:attributes).with(no_args).and_return(attrs)
      expect(device).to receive(:set_config).with(instance_of(String), instance_of(String)) do |_string, doc|
        expect(doc).to have_xml('entry/routing-table/ip/static-route/entry/bfd/profile', 'None')
        expect(doc).to have_xml('entry/routing-table/ip/static-route/entry/metric', '25')
        expect(doc).to have_xml('entry/routing-table/ip/static-route/entry/admin-dist', '15')
        expect(doc).to have_xml('entry/routing-table/ip/static-route/entry/destination', '10.9.0.1/32')
      end

      provider.create(context, resource_data[0][:route], resource_data[0])
    end
  end
  describe 'update(context, name, should)' do
    it 'calls provider functions -- For Ipv4 Static Routes' do
      allow(typedef).to receive(:attributes).with(no_args).and_return(attrs)
      expect(device).to receive(:edit_config).with(instance_of(String), instance_of(String)) do |_string, doc|
        expect(doc).to have_xml('entry/routing-table/ip/static-route/entry/bfd/profile', 'None')
        expect(doc).to have_xml('entry/routing-table/ip/static-route/entry/metric', '25')
        expect(doc).to have_xml('entry/routing-table/ip/static-route/entry/admin-dist', '15')
        expect(doc).to have_xml('entry/routing-table/ip/static-route/entry/destination', '10.9.0.1/32')
      end

      provider.update(context, resource_data[0][:route], resource_data[0])
    end
  end
  describe 'delete(context, name, vr_name)' do
    it 'calls provider functions -- For Ipv4 Static Routes' do
      allow(typedef).to receive(:attributes).with(no_args).and_return(attrs)
      expect(device).to receive(:delete_config).with("some xpath/entry[@name='#{resource_data[0][:vr_name]}']/routing-table/ip/static-route/entry[@name='#{resource_data[0][:route]}']")

      provider.delete(context, resource_data[0][:route], resource_data[0][:vr_name])
    end
  end
end

RSpec.describe Puppet::Provider::PanosStaticRouteBase do
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Panos::Device', 'device') }
  let(:typedef) { instance_double('Puppet::ResourceApi::TypeDefinition', 'typedef') }
  let(:provider) { described_class.new }
  let(:context) do
    @type =
      '<Puppet::ResourceApi::TypeDefinition:0x00007fc3323e1c80'
    @definition =
      { name: 'panos_ipv6_static_route' }
  end
  let(:attrs) do
    {
      route: {
        type:       'Pattern[/^[a-zA-z0-9\-_\s\.]*$/]',
        xpath:      'string(@name)',
        behaviour:  :namevar,
      },
      ensure: {
        type:       'Enum[present, absent]',
        default:    'present',
      },
      nexthop: {
        type:      'Optional[String]',
        xpath:     'string(nexthop/*)',
      },
      nexthop_type: {
        type:      'Optional[Enum["ip-address", "next-vr", "discard", "None"]]',
        xpath:     'local-name(nexthop/*)',
      },
      bfd_profile: {
        type:      'Optional[String]',
        xpath:     'bfd/profile/text()',
      },
      interface: {
        type:      'Optional[String]',
        xpath:     'interface/text()',
      },
      metric: {
        type:      'Optional[String]',
        xpath:     'metric/text()',
      },
      admin_distance: {
        type:      'Optional[String]',
        xpath:     'admin-dist/text()',
      },
      destination: {
        type:      'String',
        xpath:     'destination/text()',
      },
      no_install: {
        type:       'Optional[Boolean]',
        xpath:      'local-name(option/no-install)',
      },
      vr_name: {
        type:       'String',
        behaviour:  :namevar,
      },
    }
  end
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
          <ipv6>
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
          </ipv6>
        </routing-table>
      </entry>
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
        no_install: nil,
        vr_name: 'example VR',
      },
    ]
  end

  before(:each) do
    allow(context).to receive(:device).with(no_args).and_return(device)
    allow(context).to receive(:type).with(no_args).and_return(typedef)
    allow(context).to receive(:notice)
    allow(typedef).to receive(:definition).with(no_args).and_return(base_xpath: 'some xpath')

    allow(provider).to receive(:validate_should)
    allow(provider).to receive(:xml_from_should).and_return(test_entry_1)
  end

  describe 'get(context)' do
    it 'processes resources -- For Ipv6 Static Routes' do
      allow(typedef).to receive(:attributes).with(no_args).and_return(attrs)
      allow(device).to receive(:get_config).with('some xpath/entry').and_return(example_data)

      expect(provider.get(context)).to eq resource_data
    end
    it 'allows device api error to bubble up -- For Ipv6 Static Routes' do
      allow(typedef).to receive(:attributes).with(no_args).and_return(attrs)
      allow(device).to receive(:get_config).with('some xpath/entry').and_raise(Puppet::ResourceError, 'Some Error Message')

      expect { provider.get(context) }.to raise_error Puppet::ResourceError
    end
  end
  describe 'create(context, name, should)' do
    it 'calls provider functions -- For Ipv6 Static Routes' do
      allow(typedef).to receive(:attributes).with(no_args).and_return(attrs)
      expect(device).to receive(:set_config).with(instance_of(String), instance_of(String)) do |_string, doc|
        expect(doc).to have_xml('entry/routing-table/ipv6/static-route/entry/bfd/profile', 'None')
        expect(doc).to have_xml('entry/routing-table/ipv6/static-route/entry/metric', '25')
        expect(doc).to have_xml('entry/routing-table/ipv6/static-route/entry/admin-dist', '15')
        expect(doc).to have_xml('entry/routing-table/ipv6/static-route/entry/destination', '10.9.0.1/32')
      end

      provider.create(context, resource_data[0][:route], resource_data[0])
    end
  end
  describe 'update(context, name, should)' do
    it 'calls provider functions -- For Ipv6 Static Routes' do
      allow(typedef).to receive(:attributes).with(no_args).and_return(attrs)
      expect(device).to receive(:edit_config).with(instance_of(String), instance_of(String)) do |_string, doc|
        expect(doc).to have_xml('entry/routing-table/ipv6/static-route/entry/bfd/profile', 'None')
        expect(doc).to have_xml('entry/routing-table/ipv6/static-route/entry/metric', '25')
        expect(doc).to have_xml('entry/routing-table/ipv6/static-route/entry/admin-dist', '15')
        expect(doc).to have_xml('entry/routing-table/ipv6/static-route/entry/destination', '10.9.0.1/32')
      end

      provider.update(context, resource_data[0][:route], resource_data[0])
    end
  end
  describe 'delete(context, name, vr_name)' do
    it 'calls provider functions -- For Ipv6 Static Routes' do
      allow(typedef).to receive(:attributes).with(no_args).and_return(attrs)
      expect(device).to receive(:delete_config).with("some xpath/entry[@name='#{resource_data[0][:vr_name]}']/routing-table/ipv6/static-route/entry[@name='#{resource_data[0][:route]}']")

      provider.delete(context, resource_data[0][:route], resource_data[0][:vr_name])
    end
  end
end
