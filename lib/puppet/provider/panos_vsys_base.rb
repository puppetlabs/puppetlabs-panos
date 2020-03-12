require_relative 'panos_provider'

# A base provider for all PANOS providers inside a VSYS
class Puppet::Provider::PanosVsysBase < Puppet::Provider::PanosProvider
  def get(context)
    results = []
    config = context.transport.get_config('/config/devices/entry/vsys/entry')
    config.elements.collect('/response/result/entry') do |vsys_entry| # rubocop:disable Style/CollectionMethods
      result = {}
      vsys = match(vsys_entry, { xpath: 'string(@name)' }, 'name')
      vsys_entry.elements.collect("/response/result/entry/#{context.type.definition[:base_xpath]}/entry") do |entry| # rubocop:disable Style/CollectionMethods
        result = {}
        context.type.attributes.each do |attr_name, attr|
          result[attr_name] = match(entry, attr, attr_name)
        end
        result[:vsys] = vsys
        results << result
      end
    end
    results
  end

  def create(context, name, should)
    validate_should(should) if defined? validate_should
    xpath = if should[:vsys]
              "/config/devices/entry/vsys/entry[@name='#{should[:vsys]}']/#{context.type.definition[:base_xpath]}"
            else
              "/config/devices/entry/vsys/entry/#{context.type.definition[:base_xpath]}"
            end
    context.transport.set_config(xpath, xml_from_should(name, should))
    context.transport.move(context.type.definition[:base_xpath], name, should[:insert_after]) unless should[:insert_after].nil?
  end

  def update(context, name, should)
    validate_should(should) if defined? validate_should
    xpath = if should[:vsys]
              "/config/devices/entry/vsys/entry[@name='#{should[:vsys]}']/#{context.type.definition[:base_xpath]}/entry[@name='#{name}']"
            else
              "/config/devices/entry/vsys/entry/#{context.type.definition[:base_xpath]}/entry[@name='#{name}']"
            end
    context.transport.edit_config(xpath, xml_from_should(name, should))
    context.transport.move(context.type.definition[:base_xpath], name, should[:insert_after]) unless should[:insert_after].nil?
  end

  def delete(context, name)
    context.transport.delete_config("/config/devices/entry/vsys/entry/#{context.type.definition[:base_xpath]}/entry[@name='#{name}']")
  end
end
