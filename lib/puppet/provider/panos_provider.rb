require 'puppet/resource_api/simple_provider'
require 'rexml/xpath'
require 'builder'

# A base provider for all PANOS providers
class Puppet::Provider::PanosProvider < Puppet::ResourceApi::SimpleProvider
  def get(context)
    config = context.device.get_config(context.type.definition[:base_xpath] + '/entry')
    config.elements.collect('/response/result/entry') do |entry| # rubocop:disable Style/CollectionMethods
      result = {}
      context.type.attributes.each do |attr_name, attr|
        result[attr_name] = match(entry, attr, attr_name)
      end
      defined?(munge) ? munge(result) : result
    end
  end

  def create(context, name, should)
    validate_should(should) if defined? validate_should
    context.device.set_config(context.type.definition[:base_xpath], xml_from_should(name, should))
  end

  def update(context, name, should)
    validate_should(should) if defined? validate_should
    context.device.edit_config(context.type.definition[:base_xpath] + "/entry[@name='#{name}']", xml_from_should(name, should))
  end

  def delete(context, name)
    context.device.delete_config(context.type.definition[:base_xpath] + "/entry[@name='#{name}']")
  end

  def match(entry, attr, attr_name)
    return 'present' if attr_name == :ensure
    if attr.key? :xpath
      text_match(entry, attr)
    elsif attr.key? :xpath_array
      array_match(entry, attr)
    end
  end

  # PANOS uses Yes/No, convert to bool if the type expects it
  def convert_bool(value)
    return false if value.nil? || value.casecmp('no').zero?
    return true if value.casecmp('yes').zero?
    value # if it doesn't match anything
  end

  def build_tags(builder, should)
    return unless should[:tags]
    builder.tag do
      should[:tags].each do |tag|
        builder.member(tag)
      end
    end
  end

  private

  def array_match(entry, attr)
    result = REXML::XPath.match(entry, attr[:xpath_array]).map(&:to_s)
    # Allow empty array values to return nil if the value is Optional
    (result.empty? && attr[:type] =~ %r{^Optional.*}) ? nil : result
  end

  def text_match(entry, attr)
    result = REXML::XPath.match(entry, attr[:xpath]).first
    # don't convert nil values to empty strings
    return result if result.is_a? String
    result.nil? ? nil : result.value
  end
end
