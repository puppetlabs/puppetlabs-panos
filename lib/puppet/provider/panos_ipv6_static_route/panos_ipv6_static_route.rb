require 'puppet/provider/panos_static_route_base'
require 'rexml/document'
require 'builder'

# Implementation for the panos_ipv6_static_route type using the Resource API.
class Puppet::Provider::PanosIpv6StaticRoute::PanosIpv6StaticRoute < Puppet::Provider::PanosStaticRouteBase
  def initialize
    super('ipv6')
  end
end
