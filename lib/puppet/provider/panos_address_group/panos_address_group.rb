# rubocop:disable Style/CollectionMethods # REXML only knows collect(xpath), but not map(xpath)
require 'puppet/resource_api/simple_provider'
require 'rexml/document'
require 'builder'

# Implementation for the panos_address_group type using the Resource API.
class Puppet::Provider::PanosAddressGroup::PanosAddressGroup < Puppet::ResourceApi::SimpleProvider
  def get(context)
    @context ||= context
    config = context.device.get_config(context.type.definition[:base_xpath] + '/entry')
    config.elements.collect('/response/result/entry') do |entry|
      result = {
        name: entry.attributes['name'],
        ensure: 'present',
        description: text_match(entry, :description),
      }
      if !REXML::XPath.match(entry, 'static').empty?
        result[:type] = 'static'
        result[:static_members] = array_match(entry, :static_members)
      elsif !REXML::XPath.match(entry, 'dynamic').empty?
        result[:type] = 'dynamic'
        result[:dynamic_filter] = text_match(entry, :dynamic_filter)
      end
      result[:tags] = array_match(entry, :tags)
      result
    end
  end

  def array_match(entry, attr)
    REXML::XPath.match(entry, @context.type.attributes[attr][:xpath_array]).map(&:to_s)
  end

  def text_match(entry, attr)
    REXML::XPath.match(entry, @context.type.attributes[attr][:xpath]).first.to_s
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
    if should[:type] == 'static' && !should.key?(:static_members)
      raise Puppet::ResourceError, 'Static Address group must provide `static_members`'
    end
    if should[:type] == 'dynamic' && !should.key?(:dynamic_filter) # rubocop:disable Style/GuardClause # line too long
      raise Puppet::ResourceError, 'Dynamic Address group must provide `dynamic_filter`'
    end
  end

  def xml_from_should(name, should)
    builder = Builder::XmlMarkup.new
    builder.entry('name' => name) do
      builder.description(should[:description]) if should[:description]
      if should[:type] == 'static'
        builder.static do
          should[:static_members].each do |member|
            builder.member(member)
          end
        end
      elsif should[:type] == 'dynamic'
        builder.dynamic do
          builder.filter(should[:dynamic_filter])
        end
      end
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
