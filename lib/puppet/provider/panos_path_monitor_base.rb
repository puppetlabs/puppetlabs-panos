require_relative 'panos_provider'

# Implementation for the panos_path_monitor_base type using the Resource API, which has been implemented to remove the common functionality of the ipv4 and ipv6 static routes,
# which path monitors are associated with
class Puppet::Provider::PanosPathMonitorBase < Puppet::Provider::PanosProvider
  def initialize(version_label)
    super()
    @version_label = version_label
  end

  def munge(entry)
    entry[:enable] = string_to_bool(entry[:enable])
    entry
  end

  def xml_from_should(name, should)
    builder = Builder::XmlMarkup.new
    builder.entry('name' => name[:path]) do
      builder.source(should[:source])
      builder.destination(should[:destination])
      builder.interval(should[:interval])
      builder.count(should[:count])
      builder.enable(bool_to_string(should[:enable])) if should[:enable]
    end
  end

  def get(context)
    results = []
    config = context.device.get_config(context.type.definition[:base_xpath] + '/entry')
    config.elements.collect('/response/result/entry') do |entry| # rubocop:disable Style/CollectionMethods
      vr_name = REXML::XPath.match(entry, 'string(@name)').first
      config.elements.collect("/response/result/entry[@name='#{vr_name}']/routing-table/#{@version_label}/static-route/entry") do |static_route_entry| # rubocop:disable Style/CollectionMethods
        route = REXML::XPath.match(static_route_entry, 'string(@name)').first
        # rubocop:disable Metrics/LineLength
        config.elements.collect("/response/result/entry[@name='#{vr_name}']/routing-table/#{@version_label}/static-route/entry[@name='#{route}']/path-monitor/monitor-destinations/entry") do |path_monitor_entry| # rubocop:disable Style/CollectionMethods
          # rubocop:enable Metrics/LineLength
          result = {}
          context.type.attributes.each do |attr_name, attr|
            result[attr_name] = match(path_monitor_entry, attr, attr_name)
          end
          result[:route] = vr_name + '/' + route
          result[:title] = result[:route] + '/' + result[:path]
          results.push(result)
          defined?(munge) ? munge(result) : result
        end
      end
    end
    results
  end

  def create(context, name, should)
    paths = name[:route].split('/')
    context.type.definition[:base_xpath] = "/config/devices/entry/network/virtual-router/entry[@name='#{paths[0]}']/routing-table/#{@version_label}/static-route/entry[@name='#{paths[1]}']/path-monitor/monitor-destinations" # rubocop:disable Metrics/LineLength
    context.device.set_config(context.type.definition[:base_xpath], xml_from_should(name, should))
  end

  def update(context, name, should)
    paths = name[:route].split('/')
    context.type.definition[:base_xpath] = "/config/devices/entry/network/virtual-router/entry[@name='#{paths[0]}']/routing-table/#{@version_label}/static-route/entry[@name='#{paths[1]}']/path-monitor/monitor-destinations" # rubocop:disable Metrics/LineLength
    context.device.set_config(context.type.definition[:base_xpath], xml_from_should(name, should))
  end

  def delete(context, name)
    names = name[:route].split('/')
    context.device.delete_config(context.type.definition[:base_xpath] + "/entry[@name='#{names[0]}']/routing-table/#{@version_label}/static-route/entry[@name='#{names[1]}']/path-monitor/monitor-destinations/entry[@name='#{name[:path]}']") # rubocop:disable Metrics/LineLength
  end
end
