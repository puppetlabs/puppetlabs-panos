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
        <public-key>fake_key</public-key>
      </entry>
      <entry name="bob">
        <permissions>
          <role-based>
            <superuser>yes</superuser>
          </role-based>
        </permissions>
        <public-key>fake_key</public-key>
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
          expect(doc).to have_xml('entry/public-key', 'fake_key')
          expect(doc).not_to have_xml('entry/password_hash')
        end

        provider.create(context, 'user_a', name: 'user_a', ensure: 'present', ssh_key: 'fake_key', role: 'superuser')
      end
    end

    context 'when client_certificate_only' do
      it 'creates the resource' do
        expect(device).to receive(:set_config).with('some xpath', instance_of(String)) do |_xpath, doc|
          expect(doc).to have_xml('entry/client-certificate-only', 'yes')
          expect(doc).to have_xml('entry/public-key', 'fake_key')
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
          expect(doc).to have_xml('entry/public-key', 'fake_key')
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
    context 'when should contains password_hash' do
      let(:should_hash) do
        {
          name: 'bob',
          ensure: 'present',
          password_hash: '$1$pswmwlep$XonrJ7e5001tIROyO9N3Y0',
          ssh_key: 'fake_key',
          role: 'superuser',
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when should contains client_certificate_only' do
      let(:should_hash) do
        {
          name: 'bob',
          ensure: 'present',
          client_certificate_only: true,
          role: 'superuser',
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{ssh_key required when client_certificate_only is true} }
    end
    context 'when should contains client_certificate_only and ssh_key' do
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
    context 'when should contains both password_hash and client_certificate_only' do
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

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{password_hash and client_certificate_only are mutually exclusive fields} }
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

  describe 'encode_ssh(ssh_key)' do
    let(:ssh_key) do
      'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCor6qgz+3zUbQQ1YJhqgHqNjbid+cLjJAT7Hs8I1LuN523PHX+Fa6ypJVKfc+fX/eKNa7wUFZPp12w1mSm99BZuhNp9'\
      'uzUT9sz/IbRzZvBH4zLL2eSa6DWbA4XEiLurypmTkFQLib9hdFlWALeQGwjo3GqhNV+T0Nv6Z6zxwLLPtZ+vNLy7ZLpGEPtIPXidc08WTvA0zCdFaH7k82LbWU1+nOAUmd2JdlualmFbOhES'\
      '97A2/Q3uNA+vIPJ5QiyVX+6SZcCxZKMDucx73LZmQ67jXEj+MnD0+uCQwWIJ4rT2THtPoumaT7ir64ltpJvBvgOtpYHO/po5Zz4F3yVexsf578yNyOo27V9MMw+F1DO4F9BX8ITPoalugnpm'\
      'tG/QCsvxPAn6sKCK18ts7ho2fiNDAGWKB5sHQ0R1GhB7Rmy/4HpT8jfDQqh4vc7lDgA3vImNv6ht1vCadX5Ner6iKDPhj3bfsaBXd2E7dPim7gcUVhyYj6HGQVsFct9PnF4Fj65ahKtwsYFN'\
      'uy467saHifcKexT+CvgCscuwhfvT334N26D9/L50geddr4jgAPxU3wj6LpqlLK++A44U6H4z9yKOZ6vMGLiwworg/uHLynw+z7EbmE8LZN8iSsL+KXf7rraU3NJDP6m7D2xBBXHocoPDFT5lx'\
      'JobOvdI8ZliiRhrw== david.armstrong@puppet.com'
    end

    let(:encoded_ssh_key) do
      'c3NoLXJzYSBBQUFBQjNOemFDMXljMkVBQUFBREFRQUJBQUFDQVFDb3I2cWd6KzN6VWJRUTFZSmhxZ0hxTmpiaWQrY0xqSkFUN0hzOEkxTHVONTIzUEhYK0ZhNnlwSlZLZmMrZlgv'\
      'ZUtOYTd3VUZaUHAxMncxbVNtOTlCWnVoTnA5dXpVVDlzei9JYlJ6WnZCSDR6TEwyZVNhNkRXYkE0WEVpTHVyeXBtVGtGUUxpYjloZEZsV0FMZVFHd2pvM0dxaE5WK1QwTnY2WjZ6'\
      'eHdMTFB0Wit2Tkx5N1pMcEdFUHRJUFhpZGMwOFdUdkEwekNkRmFIN2s4MkxiV1UxK25PQVVtZDJKZGx1YWxtRmJPaEVTOTdBMi9RM3VOQSt2SVBKNVFpeVZYKzZTWmNDeFpLTUR1'\
      'Y3g3M0xabVE2N2pYRWorTW5EMCt1Q1F3V0lKNHJUMlRIdFBvdW1hVDdpcjY0bHRwSnZCdmdPdHBZSE8vcG81Wno0RjN5VmV4c2Y1Nzh5TnlPbzI3VjlNTXcrRjFETzRGOUJYOElUU'\
      'G9hbHVnbnBtdEcvUUNzdnhQQW42c0tDSzE4dHM3aG8yZmlOREFHV0tCNXNIUTBSMUdoQjdSbXkvNEhwVDhqZkRRcWg0dmM3bERnQTN2SW1OdjZodDF2Q2FkWDVOZXI2aUtEUGhqM2J'\
      'mc2FCWGQyRTdkUGltN2djVVZoeVlqNkhHUVZzRmN0OVBuRjRGajY1YWhLdHdzWUZOdXk0NjdzYUhpZmNLZXhUK0N2Z0NzY3V3aGZ2VDMzNE4yNkQ5L0w1MGdlZGRyNGpnQVB4VTN3a'\
      'jZMcHFsTEsrK0E0NFU2SDR6OXlLT1o2dk1HTGl3d29yZy91SEx5bncrejdFYm1FOExaTjhpU3NMK0tYZjdycmFVM05KRFA2bTdEMnhCQlhIb2NvUERGVDVseEpvYk92ZEk4WmxpaVJ'\
      'ocnc9PSBkYXZpZC5hcm1zdHJvbmdAcHVwcGV0LmNvbQ=='
    end

    context 'when ssh_key is already `encoded`' do
      it 'will not encode the value' do
        expect(provider.encode_ssh(encoded_ssh_key)).to eq(encoded_ssh_key)
      end
    end
    context 'when ssh_key is not yet `encoded`' do
      it 'will encode the value' do
        expect(provider.encode_ssh(ssh_key)).to eq(encoded_ssh_key)
      end
    end
  end
end
