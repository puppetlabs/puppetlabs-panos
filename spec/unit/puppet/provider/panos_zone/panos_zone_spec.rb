# frozen_string_literal: true

require 'spec_helper'
require 'support/shared_examples'

module Puppet::Provider::PanosZone; end
require 'puppet/provider/panos_zone/panos_zone'

RSpec.describe Puppet::Provider::PanosZone::PanosZone do
  subject(:provider) { described_class.new }

  describe 'munge(entry)' do
    context 'when boolean values are found in the entry' do
      let(:entry) do
        {
          name: 'foo',
          enable_user_identification: in_value,
          nsx_service_profile: in_value,
        }
      end
      let(:munged_entry) do
        {
          name: 'foo',
          enable_user_identification: out_value,
          nsx_service_profile: out_value,
        }
      end

      context 'when :enable_user_identification is `yes`' do
        let(:in_value) { 'Yes' }
        let(:out_value) { true }

        it { expect(provider.munge(entry)).to eq(munged_entry) }
      end
      context 'when :enable_user_identification is `yes`' do
        let(:in_value) { 'No' }
        let(:out_value) { false }

        it { expect(provider.munge(entry)).to eq(munged_entry) }
      end
    end
  end

  describe 'validate_should(should)' do
    context 'when a zone has the correct configuration to use nsx service profile' do
      let(:should_hash) do
        {
          name: 'panos_zone 1',
          ensure: 'present',
          network: 'virtual-wire',
          nsx_service_profile: true,
          zone_protection_profile: 'zoneProtectionProfile',
          log_setting: 'logFwrding',
          enable_user_identification: true,
          include_list:  ['192.35.26.32', '192.63.95.86'],
          exclude_list:  ['175.65.98.36', '175.82.36.96'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when a zone has selected to use nsx service profile, but has also selected interfaces' do
      let(:should_hash) do
        {
          name: 'panos_zone 2',
          ensure: 'present',
          network: 'virtual-wire',
          interfaces: ['vlan'],
          nsx_service_profile: true,
          zone_protection_profile: 'zoneProtectionProfile',
          log_setting: 'logFwrding',
          enable_user_identification: true,
          include_list:  ['192.35.26.32', '192.63.95.86'],
          exclude_list:  ['175.65.98.36', '175.82.36.96'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{Interfaces cannot be used with NSX Service Profile.} }
    end
    context 'when a `tunnel` supplied for `network`, but has also selected interfaces' do
      let(:should_hash) do
        {
          name: 'panos_zone 2',
          ensure: 'present',
          network: 'tunnel',
          interfaces: ['vlan'],
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{Interfaces cannot be used when `network` is set to `tunnel`.} }
    end
  end
  test_data = [
    {
      desc: 'an example with appropriate attributes',
      attrs: {
        name:                             'test zone 1',
        ensure:                           'present',
        network:                          'layer3',
        interfaces:                       ['vlan'],
        zone_protection_profile:          'zoneProtectionProfile',
        log_setting:                      'logFwrding',
        enable_user_identification:       false,
        nsx_service_profile:              false,
        include_list:                     ['192.35.26.32', '192.63.95.86'],
        exclude_list:                     ['175.65.98.36', '175.82.36.96'],
      },
      xml: '<entry name="test zone 1">
              <network>
                <layer3>
                  <member>vlan</member>
                </layer3>
                <zone-protection-profile>zoneProtectionProfile</zone-protection-profile>
                <log-setting>logFwrding</log-setting>
              </network>
              <user-acl>
                <include-list>
                  <member>192.35.26.32</member>
                  <member>192.63.95.86</member>
                </include-list>
                <exclude-list>
                  <member>175.65.98.36</member>
                  <member>175.82.36.96</member>
                </exclude-list>
              </user-acl>
          </entry>',
    },
    {
      desc: 'an example with only name, ensure and network',
      attrs: {
        name:                             'test zone 2',
        ensure:                           'present',
        network:                          'layer3',
      },
      xml: '<entry name="test zone 2">
              <network>
                <layer3/>
              </network>
          </entry>',
    },
    {
      desc: 'an example with no name',
      attrs: {
        ensure:                           'present',
        network:                          'layer3',
        interfaces:                        ['vlan'],
        zone_protection_profile:          'zoneProtectionProfile',
        log_setting:                      'logFwrding',
        enable_user_identification:       false,
        nsx_service_profile:              false,
        include_list:                     ['192.35.26.32', '192.63.95.86'],
        exclude_list:                     ['175.65.98.36', '175.82.36.96'],
      },
      xml: '<entry name="">
              <network>
                <layer3>
                  <member>vlan</member>
                </layer3>
                <zone-protection-profile>zoneProtectionProfile</zone-protection-profile>
                <log-setting>logFwrding</log-setting>
              </network>
              <user-acl>
                <include-list>
                  <member>192.35.26.32</member>
                  <member>192.63.95.86</member>
                </include-list>
                <exclude-list>
                  <member>175.65.98.36</member>
                  <member>175.82.36.96</member>
                </exclude-list>
              </user-acl>
          </entry>',
    },
    {
      desc: 'an example with NSX service profile zone and user identification enabled',
      attrs: {
        name:                             'test zone 4',
        ensure:                           'present',
        network:                          'virtual-wire',
        zone_protection_profile:          'zoneProtectionProfile',
        log_setting:                      'logFwrding',
        enable_user_identification:       true,
        nsx_service_profile:              true,
        include_list:                     ['192.35.26.32', '192.63.95.86'],
        exclude_list:                     ['175.65.98.36', '175.82.36.96'],
      },
      xml: '<entry name="test zone 4">
              <network>
                <virtual-wire/>
                <zone-protection-profile>zoneProtectionProfile</zone-protection-profile>
                <log-setting>logFwrding</log-setting>
              </network>
              <user-acl>
                <include-list>
                  <member>192.35.26.32</member>
                  <member>192.63.95.86</member>
                </include-list>
                <exclude-list>
                  <member>175.65.98.36</member>
                  <member>175.82.36.96</member>
                </exclude-list>
              </user-acl>
              <enable-user-identification>yes</enable-user-identification>
              <nsx-service-profile>yes</nsx-service-profile>
          </entry>',
    },
    {
      desc: 'an example with `enable_packet_buffer_protection` enabled',
      attrs: {
        name:                             'test zone 4',
        ensure:                           'present',
        network:                          'virtual-wire',
        enable_packet_buffer_protection:  true,
      },
      xml: '<entry name="test zone 4">
              <network>
                <virtual-wire/>
                <enable-packet-buffer-protection>yes</enable-packet-buffer-protection>
              </network>
          </entry>',
    },
    {
      desc: 'an example with `enable_packet_buffer_protection`, `enable_user_identification` and `nsx_service_profile` disabled',
      attrs: {
        name:                             'test zone 4',
        ensure:                           'present',
        network:                          'virtual-wire',
        enable_packet_buffer_protection:  false,
        enable_user_identification:       false,
        nsx_service_profile:              false,
      },
      xml: '<entry name="test zone 4">
              <network>
                <virtual-wire/>
              </network>
          </entry>',
    },
    {
      desc: 'an example with an empty include_list.',
      attrs: {
        name:                             'test zone 5',
        ensure:                           'present',
        network:                          'virtual-wire',
        zone_protection_profile:          'zoneProtectionProfile',
        log_setting:                      'logFwrding',
        enable_user_identification:       true,
        nsx_service_profile:              true,
        exclude_list:                     ['175.65.98.36', '175.82.36.96'],
      },
      xml: '<entry name="test zone 5">
              <network>
                <virtual-wire/>
                <zone-protection-profile>zoneProtectionProfile</zone-protection-profile>
                <log-setting>logFwrding</log-setting>
              </network>
              <user-acl>
                <exclude-list>
                  <member>175.65.98.36</member>
                  <member>175.82.36.96</member>
                </exclude-list>
              </user-acl>
              <enable-user-identification>yes</enable-user-identification>
              <nsx-service-profile>yes</nsx-service-profile>
          </entry>',
    },
    {
      desc: 'an example with an empty exclude_list.',
      attrs: {
        name:                             'test zone 6',
        ensure:                           'present',
        network:                          'virtual-wire',
        zone_protection_profile:          'zoneProtectionProfile',
        log_setting:                      'logFwrding',
        enable_user_identification:       true,
        nsx_service_profile:              true,
        include_list:                     ['192.35.26.32', '192.63.95.86'],
      },
      xml: '<entry name="test zone 6">
              <network>
                <virtual-wire/>
                <zone-protection-profile>zoneProtectionProfile</zone-protection-profile>
                <log-setting>logFwrding</log-setting>
              </network>
              <user-acl>
                <include-list>
                  <member>192.35.26.32</member>
                  <member>192.63.95.86</member>
                </include-list>
              </user-acl>
              <enable-user-identification>yes</enable-user-identification>
              <nsx-service-profile>yes</nsx-service-profile>
          </entry>',
    },
    {
      desc: 'an example with an empty include and exclude list',
      attrs: {
        name:                             'test zone 4',
        ensure:                           'present',
        network:                          'virtual-wire',
        zone_protection_profile:          'zoneProtectionProfile',
        log_setting:                      'logFwrding',
        enable_user_identification:       true,
        nsx_service_profile:              true,
      },
      xml: '<entry name="test zone 4">
              <network>
                <virtual-wire/>
                <zone-protection-profile>zoneProtectionProfile</zone-protection-profile>
                <log-setting>logFwrding</log-setting>
              </network>
              <enable-user-identification>yes</enable-user-identification>
              <nsx-service-profile>yes</nsx-service-profile>
          </entry>',
    },

  ]

  include_examples 'xml_from_should(name, should)', test_data, described_class.new
end
