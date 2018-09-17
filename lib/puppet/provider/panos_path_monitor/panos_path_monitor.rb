require 'puppet/provider/panos_path_monitor_base'

# Implementation for the panos_path_monitor type using the Resource API.
class Puppet::Provider::PanosPathMonitor::PanosPathMonitor < Puppet::Provider::PanosPathMonitorBase
  def initialize
    super('ip')
  end
end
