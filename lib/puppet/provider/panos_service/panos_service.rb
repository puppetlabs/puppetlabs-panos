# rubocop:disable Style/CollectionMethods # REXML only knows collect(xpath), but not map(xpath)
require 'puppet/resource_api/simple_provider'
require 'rexml/document'
require 'builder'

# Implementation for the panos_service_type type using the Resource API.
class Puppet::Provider::PanosService::PanosService < Puppet::ResourceApi::SimpleProvider
  def get(context)
    @context ||= context
    config = context.device.get_config(context.type.definition[:base_xpath] + '/entry')
    config.elements.collect('/response/result/entry') do |entry|
      result = {}
      context.type.attributes.each do |attr_name, attr|
        result[attr_name] = match(entry, attr, attr_name)
      end
      result
    end
  end

  def match(entry, attr, attr_name)
    return 'present' if attr_name == :ensure
    if attr.key? :xpath
      match_method = :text_match
    elsif attr.key? :xpath_array
      match_method = :array_match
    end
    send(match_method, entry, attr_name) if match_method
  end

  def array_match(entry, attr)
    REXML::XPath.match(entry, @context.type.attributes[attr][:xpath_array]).map(&:to_s)
  end

  def text_match(entry, attr)
    rtn_val = REXML::XPath.match(entry, @context.type.attributes[attr][:xpath]).first
    # don't convert nil values to empty strings
    rtn_val.nil? ? nil : rtn_val.to_s
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
    if should[:src_port].nil? && should[:dest_port].nil? # rubocop:disable Style/GuardClause # line too long
      raise Puppet::ResourceError, '`src_port` or `dest_port` must be provided'
    end
  end

  def xml_from_should(name, should)
    builder = Builder::XmlMarkup.new
    builder.entry('name' => name) do
      builder.protocol do
        builder.__send__(should[:protocol]) do
          builder.port(should[:dest_port]) unless should[:dest_port] == '' || should[:dest_port].nil?
          builder.__send__('source-port', should[:src_port]) unless should[:src_port] == '' || should[:src_port].nil?
        end
      end
      builder.description(should[:description]) if should[:description]
      if should[:tags]
        builder.tag do
          should[:tags].each do |tag|
            builder.member(tag)
          end
        end
      end
    end
  end
end
