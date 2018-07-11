# rubocop:disable Style/CollectionMethods # REXML only knows collect(xpath), but not map(xpath)
require 'puppet/resource_api/simple_provider'
require 'rexml/document'
require 'rexml/xpath'
require 'builder'
require 'base64'

# Implementation for the panos_admin type using the Resource API.
class Puppet::Provider::PanosAdmin::PanosAdmin < Puppet::ResourceApi::SimpleProvider
  def get(context)
    config = context.device.get_config(context.type.definition[:base_xpath] + '/entry')
    config.elements.collect('/response/result/entry') do |entry|
      result = {
        name: entry.attributes['name'],
        ensure: 'present',
      }
      context.type.attributes.select { |_k, v| v.key? :xpath }.each do |attr_name, attr|
        # match will always return an array, the xpath for this provider will always return a single value
        # grabbing the first item from the array will suffice for now.
        result[attr_name] = REXML::XPath.match(entry, attr[:xpath]).first.to_s
        result.delete(attr_name) if result[attr_name].nil? || result[attr_name] == ''
      end
      # handle conversion to boolean
      if result.key? :client_certificate_only
        result[:client_certificate_only] = ((result[:client_certificate_only] == 'yes') ? true : false)
      end
      result
    end
  end

  def create(context, name, should)
    validate_should(should)
    context.notice("Creating '#{name}' with #{should.inspect}")
    context.device.set_config(context.type.definition[:base_xpath], xml_from_should(name, should))
  end

  def update(context, name, should)
    validate_should(should)
    context.notice("Updating '#{name}' with #{should.inspect}")
    context.device.edit_config(context.type.definition[:base_xpath] + "/entry[@name='#{name}']", xml_from_should(name, should))
  end

  def delete(context, name)
    context.notice("Deleting '#{name}'")
    context.device.delete_config(context.type.definition[:base_xpath] + "/entry[@name='#{name}']")
  end

  def validate_should(should)
    if [should[:password_hash], should[:client_certificate_only]].compact.size > 1
      raise Puppet::ResourceError, 'password_hash and client_certificate_only are mutually exclusive fields'
    end
    if should[:client_certificate_only] == true && !should.key?(:ssh_key)
      raise Puppet::ResourceError, 'ssh_key required when client_certificate_only is true'
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
      elsif should[:client_certificate_only] && should[:client_certificate_only] == true
        builder.__send__('client-certificate-only', 'yes')
      end

      if should[:ssh_key]
        builder.__send__('public-key', encode_ssh(should[:ssh_key]))
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

  def encode_ssh(ssh_key)
    return ssh_key unless ssh_key =~ %r{ssh-rsa AAAA[0-9A-Za-z+/]+[=]{0,3}( [^@]+@[^@]+)?}
    Base64.strict_encode64(ssh_key)
  end
end
