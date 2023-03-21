require_relative 'panos_provider'

# A base provider for all PANOS providers inside a VSYS
class Puppet::Provider::PanosVsysBase < Puppet::Provider::PanosProvider
  def set(context, changes)
    changes.each do |name, change|
      is = if context.type.feature?('simple_get_filter')
             change.key?(:is) ? change[:is] : (get(context, [name]) || []).find { |r| r[:name] == name }
           else
             change.key?(:is) ? change[:is] : (get(context) || []).find { |r| r[:name] == name }
           end
      context.type.check_schema(is) unless change.key?(:is)

      should = change[:should]

      raise 'SimpleProvider cannot be used with a Type that is not ensurable' unless context.type.ensurable?

      is = SimpleProvider.create_absent(:name, name) if is.nil?
      should = SimpleProvider.create_absent(:name, name) if should.nil?

      name_hash = if context.type.namevars.length > 1
                    # pass a name_hash containing the values of all namevars
                    name_hash = {}
                    context.type.namevars.each do |namevar|
                      name_hash[namevar] = change[:should][namevar]
                    end
                    name_hash
                  else
                    name
                  end

      if is[:ensure].to_s == 'absent' && should[:ensure].to_s == 'present'
        context.creating(name) do
          create(context, name_hash, should)
        end
      elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'present'
        context.updating(name) do
          update(context, name_hash, should, is)
        end
      elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'absent'
        context.deleting(name) do
          delete(context, name_hash)
        end
      end
    end
  end

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

  def update(context, name, should, is)
    validate_should(should) if defined? validate_should
    if should[:vsys] == is[:vsys]
      xpath = if should[:vsys]
                "/config/devices/entry/vsys/entry[@name='#{should[:vsys]}']/#{context.type.definition[:base_xpath]}/entry[@name='#{name}']"
              else
                "/config/devices/entry/vsys/entry/#{context.type.definition[:base_xpath]}/entry[@name='#{name}']"
              end

      context.transport.edit_config("#{xpath}/entry[@name='#{name}']", xml_from_should(name, should))
      context.transport.move(context.type.definition[:base_xpath], name, should[:insert_after]) unless should[:insert_after].nil?
    else
      delete(context, name)
      create(context, name, should)
    end
  end

  def delete(context, name)
    context.transport.delete_config("/config/devices/entry/vsys/entry/#{context.type.definition[:base_xpath]}/entry[@name='#{name}']")
  end
end
