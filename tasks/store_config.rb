#!/opt/puppetlabs/puppet/bin/ruby

# work around the fact that bolt (for now, see BOLT-132) is not able to transport additional code from the module
# this requires that the panos module is pluginsynced to the node executing the task
require 'puppet'
Puppet.settings.initialize_app_defaults(
  Puppet::Settings.app_defaults_for_run_mode(
    Puppet::Util::RunMode[:agent],
  ),
)
$LOAD_PATH.unshift(Puppet[:plugindest])

# setup logging to stdout/stderr which will be available to task executors
Puppet::Util::Log.newdestination(:console)
Puppet[:log_level] = 'debug'

#### the real task ###

require 'json'
require 'puppet/util/network_device/panos/device'

params = JSON.parse(ENV['PARAMS'] || STDIN.read)
device = Puppet::Util::NetworkDevice::Panos::Device.new(params['credentials_file'])

file_name = params['config_file']
config = device.show_config

config.elements.collect('/response/result/config') do |entry| # rubocop:disable Style/CollectionMethods
  config = entry
end

File.open(file_name, 'w+') { |file| file.write(config) }
