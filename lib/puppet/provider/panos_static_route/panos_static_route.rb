require_relative '../panos_static_route_base'

# Implementation for the panos_static_route type using the Resource API.
class Puppet::Provider::PanosStaticRoute::PanosStaticRoute < Puppet::Provider::PanosStaticRouteBase
  def initialize
    super('ip')
  end
end
