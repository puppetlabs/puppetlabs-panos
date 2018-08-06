require 'puppet/provider/panos_provider'
require 'rexml/document'
require 'rexml/xpath'
require 'builder'
require 'base64'

# Implementation for the panos_admin type using the Resource API.
class Puppet::Provider::PanosAdmin::PanosAdmin < Puppet::Provider::PanosProvider
  def munge(entry)
    if entry.key?(:ssh_key) && !entry[:ssh_key].nil?
      # decode and remove trailing newline charater
      entry[:ssh_key] = Base64.strict_decode64(entry[:ssh_key])
    end
    if entry.key? :client_certificate_only
      entry[:client_certificate_only] = convert_bool(entry[:client_certificate_only])
    end
    entry
  end

  def validate_should(should)
    if should[:client_certificate_only] == true && should.key?(:password_hash)
      raise Puppet::ResourceError, 'password_hash should not be configured when client_certificate_only is true'
    end
    if should[:role] == 'custom' && !should.key?(:role_profile) # rubocop:disable Style/GuardClause # line too long
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
            builder.__send__(should[:role], 'yes')
          end
        end
      end
    end
  end
end
