# rubocop:disable Style/CollectionMethods # REXML only knows collect(xpath), but not map(xpath)
require 'puppet/resource_api/simple_provider'
require 'rexml/document'

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
    entry = REXML::Element.new 'entry'
    entry.attributes['name'] = name
    if should[:description]
      entry.elements << REXML::Element.new('description').add_text(should[:description])
    end
    if should[:type] == 'static'
      static_ele = REXML::Element.new('static')
      should[:static_members].each do |member|
        static_ele.add_element(REXML::Element.new('member').add_text(member))
      end
      entry.add_element(static_ele)
    elsif should[:type] == 'dynamic'
      dynamic_ele = REXML::Element.new('dynamic')
      filter = REXML::Element.new('filter').add_text(should[:dynamic_filter])
      dynamic_ele.add_element(filter)
      entry.elements << dynamic_ele
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
    # require 'pry'; binding.pry
    result
  end
end
