require 'puppet/provider/panos_static_route_base'
require 'rexml/document'
require 'builder'

# Implementation for the panos_ipv6_static_route type using the Resource API.
class Puppet::Provider::PanosIpv6StaticRoute::PanosIpv6StaticRoute < Puppet::Provider::PanosStaticRouteBase
  def munge(entry)
    entry[:no_install] = entry[:no_install].nil? ? false : true
    entry[:nexthop_type] = 'None' if entry[:nexthop_type].nil?
    entry
  end
end
