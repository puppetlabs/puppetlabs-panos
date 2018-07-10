require 'spec_helper'
require 'support/matchers/have_xml'

# TODO: needs some cleanup/helper to avoid this misery
module Puppet::Provider::PanosAdmin; end
require 'puppet/provider/panos_admin/panos_admin'

RSpec.describe Puppet::Provider::PanosAdmin::PanosAdmin do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:device) { instance_double('Puppet::Util::NetworkDevice::Panos::Device', 'device') }
  let(:typedef) { instance_double('Puppet::ResourceApi::TypeDefinition', 'typedef') }
  let(:example_data) do
    REXML::Document.new <<EOF
    <response status="success" code="19">
    <result total-count="7" count="7">
      <entry name="admin">
        <phash>fnRL/G5lXVMug</phash>
        <permissions>
          <role-based>
            <superuser>yes</superuser>
          </role-based>
        </permissions>
      </entry>
      <entry name="dave">
        <permissions>
          <role-based>
            <superuser>yes</superuser>
          </role-based>
        </permissions>
        <client-certificate-only>yes</client-certificate-only>
        <public-key>ZmFrZV9rZXk=</public-key>
      </entry>
      <entry name="bob">
        <permissions>
          <role-based>
            <superuser>yes</superuser>
          </role-based>
        </permissions>
        <public-key>ZmFrZV9rZXk=</public-key>
        <phash>$1$pswmwlep$XonrJ7e5001tIROyO9N3Y0</phash>
      </entry>
      <entry name="bert">
        <permissions>
          <role-based>
            <custom>
              <profile>securityadmin</profile>
            </custom>
          </role-based>
        </permissions>
        <phash>$1$qgxmiors$DBWTUbkT/oXkhI8c6K7ki0</phash>
      </entry>
      <entry name="user_SURO">
        <permissions>
          <role-based>
            <superreader>yes</superreader>
          </role-based>
        </permissions>
        <phash>$1$tyoftdlo$Ni6feDFrhonM89nC7K60D0</phash>
      </entry>
      <entry name="user_Device">
        <permissions>
          <role-based>
            <superuser>yes</superuser>
          </role-based>
        </permissions>
        <phash>$1$hkmwrshs$7ggsVRsisxmZEbfqxXOyv1</phash>
      </entry>
      <entry name="user_DeviceRO">
        <permissions>
          <role-based>
            <devicereader/>
          </role-based>
        </permissions>
        <phash>$1$ftyywknf$WkqGxvEBfJkZLgY30FiGT.</phash>
      </entry>
    </result>
  </response>
EOF
  end

  before(:each) do
    allow(context).to receive(:device).with(no_args).and_return(device)
    allow(context).to receive(:type).with(no_args).and_return(typedef)
    allow(context).to receive(:notice)
    allow(typedef).to receive(:definition).with(no_args).and_return(base_xpath: 'some xpath')
  end

  describe '#get' do
    it 'processes resources' do
      allow(typedef).to receive(:attributes).with(no_args).and_return(password_hash: { xpath: 'phash/text()' },
                                                                      client_certificate_only: { xpath: 'client-certificate-only/text()' },
                                                                      ssh_key: { xpath: 'public-key/text()' },
                                                                      role: { xpath: 'local-name(permissions/role-based/*[1])' },
                                                                      role_profile: { xpath: 'permissions/role-based/custom/profile/text()' })
      allow(device).to receive(:get_config).with('some xpath/entry').and_return(example_data)

      expect(provider.get(context)).to eq [
        {
          name: 'admin',
          ensure: 'present',
          password_hash: 'fnRL/G5lXVMug',
          role: 'superuser',
        },
        {
          name: 'dave',
          ensure: 'present',
          client_certificate_only: true,
          ssh_key: 'fake_key',
          role: 'superuser',
        },
        {
          name: 'bob',
          ensure: 'present',
          password_hash: '$1$pswmwlep$XonrJ7e5001tIROyO9N3Y0',
          ssh_key: 'fake_key',
          role: 'superuser',
        },
        {
          name: 'bert',
          ensure: 'present',
          password_hash: '$1$qgxmiors$DBWTUbkT/oXkhI8c6K7ki0',
          role: 'custom',
          role_profile: 'securityadmin',
        },
        {
          name: 'user_SURO',
          ensure: 'present',
          password_hash: '$1$tyoftdlo$Ni6feDFrhonM89nC7K60D0',
          role: 'superreader',
        },
        {
          name: 'user_Device',
          ensure: 'present',
          password_hash: '$1$hkmwrshs$7ggsVRsisxmZEbfqxXOyv1',
          role: 'superuser',
        },
        {
          name: 'user_DeviceRO',
          ensure: 'present',
          password_hash: '$1$ftyywknf$WkqGxvEBfJkZLgY30FiGT.',
          role: 'devicereader',
        },
      ]
    end
  end

  describe 'create(context, name, should)' do
    before(:each) do
      allow(device).to receive(:set_config)
    end

    it 'logs the call' do
      expect(context).to receive(:notice).with(%r{\ACreating 'user_a'})
      provider.create(context, 'user_a', name: 'user_a', ensure: 'present', password_hash: '12345', role: 'superuser')
    end

    it 'uses the correct base structure' do
      expect(device).to receive(:set_config).with('some xpath', instance_of(String)) do |_xpath, doc|
        expect(doc).to have_xml("entry[@name='user_a']")
      end
      provider.create(context, 'user_a', name: 'user_a', ensure: 'present', password_hash: '12345', role: 'superuser')
    end

    context 'when providing a password_hash' do
      it 'creates the resource' do
        expect(device).to receive(:set_config).with('some xpath', instance_of(String)) do |_xpath, doc|
          expect(doc).to have_xml('entry/phash', '12345')
          expect(doc).not_to have_xml('entry/public-key')
        end

        provider.create(context, 'user_a', name: 'user_a', ensure: 'present', password_hash: '12345', role: 'superuser')
      end
    end

    context 'when providing an ssh_key' do
      it 'creates the resource' do
        expect(device).to receive(:set_config).with('some xpath', instance_of(String)) do |_xpath, doc|
          expect(doc).to have_xml('entry/public-key', 'ZmFrZV9rZXk=')
          expect(doc).not_to have_xml('entry/password_hash')
        end

        provider.create(context, 'user_a', name: 'user_a', ensure: 'present', ssh_key: 'fake_key', role: 'superuser')
      end
    end

    context 'when client_certificate_only' do
      it 'creates the resource' do
        expect(device).to receive(:set_config).with('some xpath', instance_of(String)) do |_xpath, doc|
          expect(doc).to have_xml('entry/client-certificate-only', 'yes')
          expect(doc).to have_xml('entry/public-key', 'ZmFrZV9rZXk=')
        end

        provider.create(context, 'user_a', name: 'user_a', ensure: 'present', ssh_key: 'fake_key', client_certificate_only: true, role: 'superuser')
      end
    end

    context 'when user is superreader' do
      it 'creates the resource' do
        expect(device).to receive(:set_config).with('some xpath', instance_of(String)) do |_xpath, doc|
          expect(doc).to have_xml('entry/permissions/role-based/superreader')
          expect(doc).not_to have_xml('permissions/role-based/custom')
        end

        provider.create(context, 'user_a', name: 'user_a', ensure: 'present', password_hash: '12345', role: 'superreader')
      end
    end

    context 'when user is devicereader' do
      it 'creates the resource' do
        expect(device).to receive(:set_config).with('some xpath', instance_of(String)) do |_xpath, doc|
          expect(doc).to have_xml('entry/permissions/role-based/devicereader')
          expect(doc).not_to have_xml('permissions/role-based/custom')
        end

        provider.create(context, 'user_a', name: 'user_a', ensure: 'present', password_hash: '12345', role: 'devicereader')
      end
    end

    context 'when user has a custom role' do
      it 'creates the resource' do
        expect(device).to receive(:set_config).with('some xpath', instance_of(String)) do |_xpath, doc|
          expect(doc).to have_xml('entry/permissions/role-based/custom')
          expect(doc).to have_xml('entry/permissions/role-based/custom/profile', 'wibble')
        end

        provider.create(context, 'user_a', name: 'user_a', ensure: 'present', password_hash: '12345', role: 'custom', role_profile: 'wibble')
      end
    end
  end

  describe 'update(context, name, should)' do
    before(:each) do
      allow(device).to receive(:edit_config)
    end

    it 'logs the call' do
      expect(context).to receive(:notice).with(%r{\AUpdating 'bob'})
      provider.update(context, 'bob', name: 'bob', ensure: 'present', password_hash: '12345', role: 'superuser')
    end

    it 'uses the correct base structure' do
      expect(device).to receive(:edit_config).with("some xpath/entry[@name='bob']", instance_of(String)) do |_xpath, doc|
        expect(doc).to have_xml("entry[@name='bob']")
      end
      provider.update(context, 'bob', name: 'bob', ensure: 'present', password_hash: '12345', role: 'superuser')
    end

    context 'when providing a password_hash' do
      it 'creates the resource' do
        expect(device).to receive(:edit_config).with('some xpath/entry[@name=\'bob\']', instance_of(String)) do |_xpath, doc|
          expect(doc).to have_xml('entry/phash', '12345')
          expect(doc).not_to have_xml('entry/public-key')
        end

        provider.update(context, 'bob', name: 'bob', ensure: 'present', password_hash: '12345', role: 'superuser')
      end
    end

    context 'when providing an ssh_key' do
      it 'creates the resource' do
        expect(device).to receive(:edit_config).with('some xpath/entry[@name=\'bob\']', instance_of(String)) do |_xpath, doc|
          expect(doc).to have_xml('entry/public-key', 'ZmFrZV9rZXk=')
          expect(doc).not_to have_xml('entry/password_hash')
        end

        provider.update(context, 'bob', name: 'bob', ensure: 'present', ssh_key: 'fake_key', role: 'superuser')
      end
    end

    context 'when user is superreader' do
      it 'creates the resource' do
        expect(device).to receive(:edit_config).with('some xpath/entry[@name=\'bob\']', instance_of(String)) do |_xpath, doc|
          expect(doc).to have_xml('entry/permissions/role-based/superreader')
          expect(doc).not_to have_xml('permissions/role-based/custom')
        end

        provider.update(context, 'bob', name: 'bob', ensure: 'present', password_hash: '12345', role: 'superreader')
      end
    end

    context 'when user is devicereader' do
      it 'creates the resource' do
        expect(device).to receive(:edit_config).with('some xpath/entry[@name=\'bob\']', instance_of(String)) do |_xpath, doc|
          expect(doc).to have_xml('entry/permissions/role-based/devicereader')
          expect(doc).not_to have_xml('permissions/role-based/custom')
        end

        provider.update(context, 'bob', name: 'bob', ensure: 'present', password_hash: '12345', role: 'devicereader')
      end
    end

    context 'when user has a custom role' do
      it 'creates the resource' do
        expect(device).to receive(:edit_config).with('some xpath/entry[@name=\'bob\']', instance_of(String)) do |_xpath, doc|
          expect(doc).to have_xml('entry/permissions/role-based/custom')
          expect(doc).to have_xml('entry/permissions/role-based/custom/profile', 'wibble')
        end

        provider.update(context, 'bob', name: 'bob', ensure: 'present', password_hash: '12345', role: 'custom', role_profile: 'wibble')
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
end
