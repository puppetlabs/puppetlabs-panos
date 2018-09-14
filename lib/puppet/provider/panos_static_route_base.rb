require 'puppet/provider/panos_provider'
require 'rexml/document'
require 'builder'

# Implementation for the panos_static_route_base type using the Resource API, which has been implemented to remove the common functionality of the ipv4 and ipv6 static routes.
class Puppet::Provider::PanosStaticRouteBase < Puppet::Provider::PanosProvider
  def initialize(version_label)
    @version_label = version_label
  end

  def munge(entry)
    entry[:no_install] = entry[:no_install].nil? ? false : true
    entry[:nexthop_type] = 'none' if entry[:nexthop_type].nil?
    entry
  end

  def set(context, changes) # Overriding set to provide the delete method with the vr_name, in order to specify the route to be deleted
    changes.each do |name, change|
      is = change.key?(:is) ? change[:is] : (get(context) || []).find { |r| r[:name] == name }

      context.type.check_schema(is) unless change.key?(:is)

      should = change[:should]

      raise 'PanosStaticRouteBase cannot be used with a Type that is not ensurable' unless context.type.ensurable?

      is = { route: name, ensure: 'absent' } if is.nil?
      should = { route: name, ensure: 'absent' } if should.nil?

      if is[:ensure].to_s == 'absent' && should[:ensure].to_s == 'present'
        context.creating(name) do
          create(context, name, should)
        end
      elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'present'
        context.updating(name) do
          update(context, name, should)
        end
      elsif is[:ensure].to_s == 'present' && should[:ensure].to_s == 'absent'
        context.deleting(should[:route]) do
          delete(context, should[:route], should[:vr_name])
        end
      end
    end
  end

  def xml_from_should(_name, should)
    builder = Builder::XmlMarkup.new
    builder.entry('name' => should[:route]) do
      unless should[:nexthop_type] == 'none'
        builder.nexthop do
          builder.__send__(should[:nexthop_type], should[:nexthop]) unless should[:nexthop_type] == 'discard'
          builder.discard if should[:nexthop_type] == 'discard'
        end
      end
      if should[:bfd_profile]
        builder.bfd do
          builder.profile(should[:bfd_profile])
        end
      end
      builder.interface(should[:interface]) if should[:interface]
      builder.metric(should[:metric]) if should[:metric]
      builder.__send__('admin-dist', should[:admin_distance]) if should[:admin_distance]
      builder.destination(should[:destination]) if should[:destination]
      if should[:no_install]
        builder.option do
          builder.__send__('no-install')
        end
      end
    end
  end

  def validate_should(should)
    raise Puppet::ResourceError, 'Interfaces must be provided if no Next Hop or Virtual Router is specified for next hop.' if should[:interface].nil? && should[:nexthop_type] != 'discard'
    raise Puppet::ResourceError, "BFD requires a nexthop_type to be `#{@version_label}-address`" if should[:bfd_profile] != 'None' && should[:nexthop_type] !~ %r{^ip(?:v6)?-address$}
  end

  # Overiding the get method, as the base xpath points towards virtual routers, and therefore the base provider's get will only return once for each VR.
  def get(context)
    results = []
    config = context.device.get_config(context.type.definition[:base_xpath] + '/entry')
    config.elements.collect('/response/result/entry') do |entry| # rubocop:disable Style/CollectionMethods
      vr_name = REXML::XPath.match(entry, 'string(@name)').first
      # rubocop:disable Style/CollectionMethods
      config.elements.collect("/response/result/entry[@name='#{vr_name}']/routing-table/#{@version_label}/static-route/entry") do |static_route_entry|
        result = {}
        context.type.attributes.each do |attr_name, attr|
          result[attr_name] = match(static_route_entry, attr, attr_name) unless attr_name == :vr_name
        end
        result[:vr_name] = vr_name
        results.push(result)
        defined?(munge) ? munge(result) : result
      end
      # rubocop:enable Style/CollectionMethods
    end
    results
  end

  # Overiding the following methods to point the xpath into the correct VR.
  def create(context, _name, should)
    context.type.definition[:base_xpath] = "/config/devices/entry/network/virtual-router/entry[@name='#{should[:vr_name]}']/routing-table/#{@version_label}/static-route"
    validate_should(should)
    context.device.set_config(context.type.definition[:base_xpath], xml_from_should(should[:name], should))
  end

  def update(context, _name, should)
    context.type.definition[:base_xpath] = "/config/devices/entry/network/virtual-router/entry[@name='#{should[:vr_name]}']/routing-table/#{@version_label}/static-route"
    validate_should(should)
    context.device.set_config(context.type.definition[:base_xpath], xml_from_should(should[:name], should))
  end

  def delete(context, name, vr_name)
    context.device.delete_config(context.type.definition[:base_xpath] + "/entry[@name='#{vr_name}']/routing-table/#{@version_label}/static-route/entry[@name='#{name}']")
  end
end
