require 'puppet/provider/panos_provider'
require 'rexml/document'
require 'builder'

# Implementation for the panos_address type using the Resource API.
class Puppet::Provider::PanosAddress::PanosAddress < Puppet::Provider::PanosProvider
  def validate_should(should)
    if [should[:ip_netmask], should[:ip_range], should[:fqdn]].compact.size > 1 # rubocop:disable Style/GuardClause # line too long
      raise Puppet::ResourceError, 'ip_netmask, ip_range, and fqdn are mutually exclusive fields'
    end
  end

  def xml_from_should(name, should)
    builder = Builder::XmlMarkup.new
    builder.entry('name' => name) do
      builder.description(should[:description]) if should[:description]
      if should[:ip_netmask]
        builder.__send__('ip-netmask', should[:ip_netmask])
      elsif should[:ip_range]
        builder.__send__('ip-range', should[:ip_range])
      elsif should[:fqdn]
        builder.fqdn(should[:fqdn])
      end
      build_tags(builder, should)
    end
  end
end
