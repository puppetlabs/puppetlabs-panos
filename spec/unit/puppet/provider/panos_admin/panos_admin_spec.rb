require 'spec_helper'
require 'support/shared_examples'

module Puppet::Provider::PanosAdmin; end
require 'puppet/provider/panos_admin/panos_admin'

RSpec.describe Puppet::Provider::PanosAdmin::PanosAdmin do
  subject(:provider) { described_class.new }

  describe 'munge(entry)' do
    context 'when is :ssh_key is found in the entry' do
      let(:decoded_entry) do
        {
          name: 'foo',
          ssh_key: 'test',
        }
      end

      context 'with new lines' do
        let(:entry) do
          {
            name: 'foo',
            ssh_key: "\ndGVzdA==\n\n",
          }
        end

        it { expect(provider.munge(entry)).to eq(decoded_entry) }
      end
      context 'with no new lines' do
        let(:entry) do
          {
            name: 'foo',
            ssh_key: 'dGVzdA==',
          }
        end

        it { expect(provider.munge(entry)).to eq(decoded_entry) }
      end
    end

    context 'when is :ssh_key is NOT found in the entry' do
      let(:entry) do
        {
          name: 'foo',
          desc: 'dGVzdA==',
        }
      end

      it { expect(provider.munge(entry)).to eq(entry) }
    end
    context 'when :client_certificate_only is found in the entry' do
      let(:entry) do
        {
          name: 'foo',
          client_certificate_only: 'Yes',
        }
      end
      let(:munged_entry) do
        {
          name: 'foo',
          client_certificate_only: true,
        }
      end

      it { expect(provider.munge(entry)).to eq(munged_entry) }
    end
  end

  describe 'validate_should(should)' do
    context 'when client_certificate_only is true and should contains password_hash' do
      let(:should_hash) do
        {
          name: 'bob',
          ensure: 'present',
          password_hash: '$1$pswmwlep$XonrJ7e5001tIROyO9N3Y0',
          client_certificate_only: true,
          ssh_key: 'fake_key',
          role: 'superuser',
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{password_hash should not be configured when client_certificate_only is true} }
    end
    context 'when client_certificate_only is false and should contains password_hash' do
      let(:should_hash) do
        {
          name: 'bob',
          ensure: 'present',
          password_hash: '$1$pswmwlep$XonrJ7e5001tIROyO9N3Y0',
          client_certificate_only: false,
          ssh_key: 'fake_key',
          role: 'superuser',
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when client_certificate_only is true' do
      let(:should_hash) do
        {
          name: 'bob',
          ensure: 'present',
          client_certificate_only: true,
          ssh_key: 'fake_key',
          role: 'superuser',
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when should contains authentication_profile' do
      let(:should_hash) do
        {
          name: 'bob',
          ensure: 'present',
          authentication_profile: 'profile',
          ssh_key: 'fake_key',
          role: 'superuser',
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when client_certificate_only is true and should contains authentication_profile' do
      let(:should_hash) do
        {
          name: 'bob',
          ensure: 'present',
          authentication_profile: 'profile',
          client_certificate_only: true,
          ssh_key: 'fake_key',
          role: 'superuser',
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{authentication_profile should not be configured when client_certificate_only is true} }
    end
    context 'when client_certificate_only is false and should contains authentication_profile' do
      let(:should_hash) do
        {
          name: 'bob',
          ensure: 'present',
          authentication_profile: 'profile',
          client_certificate_only: false,
          ssh_key: 'fake_key',
          role: 'superuser',
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when should contains both authentication_profile and password_hash' do
      let(:should_hash) do
        {
          name: 'bob',
          ensure: 'present',
          authentication_profile: 'profile',
          password_hash: '$1$pswmwlep$XonrJ7e5001tIROyO9N3Y0',
          ssh_key: 'fake_key',
          role: 'superuser',
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{authentication_profile should not be configured when password_hash is configured} }
    end
    context 'when should contains both custom role and role_profile' do
      let(:should_hash) do
        {
          name: 'bob',
          ensure: 'present',
          password_hash: '$1$pswmwlep$XonrJ7e5001tIROyO9N3Y0',
          role: 'custom',
          role_profile: 'foo',
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when should contains custom role but no role_profile' do
      let(:should_hash) do
        {
          name: 'bob',
          ensure: 'present',
          password_hash: '$1$pswmwlep$XonrJ7e5001tIROyO9N3Y0',
          role: 'custom',
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{Role based administrator type missing role_profile} }
    end
  end

  test_data = [
    {
      desc: 'a basic administrator account',
      attrs: {
        name:           'basic',
        ensure:         'present',
        password_hash:  'fnRL/G5lXVMug',
        role:           'superuser',
      },
      xml: '<entry name="basic">
            <phash>fnRL/G5lXVMug</phash>
            <permissions>
              <role-based>
                <superuser>yes</superuser>
              </role-based>
            </permissions>
            </entry>',
    },
    {
      desc: 'an account with client certificate enabled',
      attrs: {
        name: 'cert_enabled',
        ensure: 'present',
        client_certificate_only: true,
        ssh_key: 'fake_key',
        role: 'superuser',
      },
      xml: '<entry name="cert_enabled">
              <client-certificate-only>yes</client-certificate-only>
              <public-key>ZmFrZV9rZXk=</public-key>
              <permissions>
                <role-based>
                  <superuser>yes</superuser>
                </role-based>
              </permissions>
            </entry>',
    },
    {
      desc: 'an account with client certificate disabled',
      attrs: {
        name: 'cert_enabled',
        ensure: 'present',
        client_certificate_only: false,
        ssh_key: 'fake_key',
        role: 'superuser',
      },
      xml: '<entry name="cert_enabled">
              <public-key>ZmFrZV9rZXk=</public-key>
              <permissions>
                <role-based>
                  <superuser>yes</superuser>
                </role-based>
              </permissions>
            </entry>',
    },
    {
      desc: 'an ssh_enabled account',
      attrs: {
        name:           'ssh_enabled',
        ensure:         'present',
        password_hash:  '$1$pswmwlep$XonrJ7e5001tIROyO9N3Y0',
        ssh_key:        'fake_key',
        role:           'superuser',
      },
      xml:  '<entry name="ssh_enabled">
              <phash>$1$pswmwlep$XonrJ7e5001tIROyO9N3Y0</phash>
              <public-key>ZmFrZV9rZXk=</public-key>
              <permissions>
                <role-based>
                  <superuser>yes</superuser>
                </role-based>
              </permissions>
            </entry>',
    },
    {
      desc: 'a security administrator account',
      attrs: {
        name:           'securityadmin_user',
        ensure:         'present',
        password_hash:  '$1$qgxmiors$DBWTUbkT/oXkhI8c6K7ki0',
        role:           'custom',
        role_profile:   'securityadmin',
      },
      xml: '<entry name="securityadmin_user">
              <phash>$1$qgxmiors$DBWTUbkT/oXkhI8c6K7ki0</phash>
              <permissions>
                <role-based>
                  <custom>
                    <profile>securityadmin</profile>
                  </custom>
                </role-based>
              </permissions>
            </entry>',
    },
    {
      desc: 'a read-only user account',
      attrs: {
        name:           'user_SURO',
        ensure:         'present',
        password_hash:  '$1$tyoftdlo$Ni6feDFrhonM89nC7K60D0',
        role:           'superreader',
      },
      xml:  '<entry name="user_SURO">
              <phash>$1$tyoftdlo$Ni6feDFrhonM89nC7K60D0</phash>
              <permissions>
                <role-based>
                  <superreader>yes</superreader>
                </role-based>
              </permissions>
            </entry>',
    },
    {
      desc: 'a device user account',
      attrs: {
        name:           'user_Device',
        ensure:         'present',
        password_hash:  '$1$hkmwrshs$7ggsVRsisxmZEbfqxXOyv1',
        role:           'superuser',
      },
      xml:  '<entry name="user_Device">
              <phash>$1$hkmwrshs$7ggsVRsisxmZEbfqxXOyv1</phash>
              <permissions>
                <role-based>
                  <superuser>yes</superuser>
                </role-based>
              </permissions>
            </entry>',
    },
    {
      desc: 'a device user account with read-only access',
      attrs: {
        name:           'user_DeviceRO',
        ensure:         'present',
        password_hash:  '$1$ftyywknf$WkqGxvEBfJkZLgY30FiGT.',
        role:           'devicereader',
      },
      xml: '<entry name="user_DeviceRO">
              <phash>$1$ftyywknf$WkqGxvEBfJkZLgY30FiGT.</phash>
              <permissions>
                <role-based>
                  <devicereader/>
                </role-based>
              </permissions>
            </entry>',
    },
    {
      desc: 'an authentication_profile set',
      attrs: {
        name:                    'user_DeviceRO',
        ensure:                  'present',
        authentication_profile:  'profile',
        role:                    'devicereader',
      },
      xml: '<entry name="user_DeviceRO">
              <authentication-profile>profile</authentication-profile>
              <permissions>
                <role-based>
                  <devicereader/>
                </role-based>
              </permissions>
            </entry>',
    },
  ]

  include_examples 'xml_from_should(name, should)', test_data, described_class.new
end
