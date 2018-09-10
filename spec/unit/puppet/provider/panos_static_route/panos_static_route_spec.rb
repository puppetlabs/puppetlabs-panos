require 'spec_helper'
require 'support/matchers/have_xml'
require 'support/shared_examples'

module Puppet::Provider::PanosStaticRoute; end
require 'puppet/provider/panos_static_route/panos_static_route'

RSpec.describe Puppet::Provider::PanosStaticRoute::PanosStaticRoute do
  subject(:provider) { described_class.new }

  describe 'munge(entry)' do
    context 'when the static route is configured with a no install option' do
      let(:entry) do
        {
          route: 'test route',
          no_install: 'no-install',
          vr_name: 'test vr',
        }
      end
      let(:result) { { no_install: true } }

      it { expect(provider.munge(entry)[:no_install]).to eq(result[:no_install]) }
    end
    context 'when the static route is configured without a no install option' do
      let(:entry) do
        {
          route: 'test route',
          vr_name: 'test vr',
        }
      end
      let(:result) { { no_install: false } }

      it { expect(provider.munge(entry)[:no_install]).to eq(result[:no_install]) }
    end
    context 'when the static route is configured without nexthop' do
      let(:entry) do
        {
          route: 'test route',
          vr_name: 'test vr',
        }
      end
      let(:result) { { nexthop_type: 'none' } }

      it { expect(provider.munge(entry)[:nexthop_type]).to eq(result[:nexthop_type]) }
    end
    context 'when the static route is configured with nexthop' do
      let(:entry) do
        {
          route: 'test route',
          nexthop_type: 'ip-address',
          vr_name: 'test vr',
        }
      end
      let(:result) { { nexthop_type: 'ip-address' } }

      it { expect(provider.munge(entry)[:nexthop_type]).to eq(result[:nexthop_type]) }
    end
  end

  describe 'validate_should(should)' do
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

      it { expect { provider.validate_should(entry) }.to raise_error Puppet::ResourceError, %r{ must be provided if no Next Hop or Virtual Router is specified for next} }
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

      it { expect { provider.validate_should(entry) }.to raise_error Puppet::ResourceError, %r{ requires a nexthop ip address to be } }
    end
    context 'when the static route uses a BFD profile, and is configured to use a nexthop ip' do
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
  end

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

  include_examples 'xml_from_should(name, should)', test_data, described_class.new
end
