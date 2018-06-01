# rubocop:disable Style/CollectionMethods # REXML only knows collect(xpath), but not map(xpath)
require 'puppet/resource_api/simple_provider'
require 'rexml/document'

# Implementation for the panos_address type using the Resource API.
class Puppet::Provider::PanosAddress::PanosAddress < Puppet::ResourceApi::SimpleProvider
  def get(context)
    config = context.device.get_config(context.type.definition[:base_xpath] + '/entry')
    config.elements.collect('/response/result/entry') do |entry|
      result = {
        name: entry.attributes['name'],
        ensure: 'present',
      }
      context.type.attributes.select { |_k, v| v.key? :xpath }.each do |attr_name, attr|
        result[attr_name] = entry.text(attr[:xpath])
      end
      result[:tags] = entry.elements.collect('tag/member') { |t| t.text } if context.type.attributes.key? :tags
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
    if [should[:ip_netmask], should[:ip_range], should[:fqdn]].compact.size > 1
      raise Puppet::ResourceError, 'ip_netmask, ip_range, and fqdn are mutually exclusive fields'
    end
  end

  def xml_from_should(name, should)
    entry = REXML::Element.new 'entry'
    entry.attributes['name'] = name
    if should[:description]
      entry.elements << REXML::Element.new('description').add_text(should[:description])
    end
    if should[:ip_netmask]
      entry.elements << REXML::Element.new('ip-netmask').add_text(should[:ip_netmask])
    elsif should[:ip_range]
      entry.elements << REXML::Element.new('ip-range').add_text(should[:ip_range])
    elsif should[:fqdn]
      entry.elements << REXML::Element.new('fqdn').add_text(should[:fqdn])
    end
    if should[:tags]
      base_tag = REXML::Element.new('tag')
      should[:tags].each do |tag|
        base_tag.elements << REXML::Element.new('member').add_text(tag)
      end
      entry.elements << base_tag
    end
    result = REXML::Document.new
    result.elements << entry
    result
  end
end
