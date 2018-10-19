require_relative '../panos_path_monitor_base'

# Implementation for the panos_ipv6_path_monitor type using the Resource API.
class Puppet::Provider::PanosIpv6PathMonitor::PanosIpv6PathMonitor < Puppet::Provider::PanosPathMonitorBase
  def initialize
    super('ipv6')
  end
end
