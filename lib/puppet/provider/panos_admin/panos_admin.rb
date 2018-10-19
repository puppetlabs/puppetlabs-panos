require_relative '../panos_provider'
require 'rexml/document'
require 'rexml/xpath'
require 'builder'
require 'base64'

# Implementation for the panos_admin type using the Resource API.
class Puppet::Provider::PanosAdmin::PanosAdmin < Puppet::Provider::PanosProvider
  def munge(entry)
    if entry.key?(:ssh_key) && !entry[:ssh_key].nil?
      # remove newline characters that can mess up the decode
      entry[:ssh_key] = Base64.strict_decode64(entry[:ssh_key].strip)
    end
    if entry.key? :client_certificate_only
      entry[:client_certificate_only] = string_to_bool(entry[:client_certificate_only])
    end
    entry
  end

  def validate_should(should)
    if should[:client_certificate_only] == true && should[:password_hash] # rubocop:disable Style/GuardClause
      raise Puppet::ResourceError, 'password_hash should not be configured when client_certificate_only is true'
    elsif should[:client_certificate_only] == true && should[:authentication_profile]
      raise Puppet::ResourceError, 'authentication_profile should not be configured when client_certificate_only is true'
    elsif should[:password_hash] && should[:authentication_profile]
      raise Puppet::ResourceError, 'authentication_profile should not be configured when password_hash is configured'
    end
    if should[:role] == 'custom' && !should.key?(:role_profile) # rubocop:disable Style/GuardClause
      raise Puppet::ResourceError, 'Role based administrator type missing role_profile'
    end
  end

  def xml_from_should(name, should)
    builder = Builder::XmlMarkup.new
    builder.entry('name' => name) do
      if should[:password_hash]
        builder.phash(should[:password_hash])
      elsif should[:client_certificate_only]
        builder.__send__('client-certificate-only', 'yes')
      elsif should[:authentication_profile]
        builder.__send__('authentication-profile', should[:authentication_profile])
      end
      if should[:ssh_key]
        builder.__send__('public-key', Base64.strict_encode64(should[:ssh_key]))
      end
      builder.permissions do
        builder.__send__('role-based') do
          if should[:role] == 'custom'
            builder.custom do
              builder.profile(should[:role_profile])
            end
          else
            self_closing_roles = ['devicereader', 'deviceadmin']
            if self_closing_roles.include? should[:role]
              builder.__send__(should[:role])
            else
              builder.__send__(should[:role], 'yes')
            end
          end
        end
      end
    end
  end
end
