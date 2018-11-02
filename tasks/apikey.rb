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

def add_plugin_paths(install_dir)
  Dir.glob(File.join([install_dir, '*'])).each do |mod|
    $LOAD_PATH << File.join([mod, "lib"])
  end
end

params = JSON.parse(ENV['PARAMS'] || STDIN.read)
#params = {key: "foo"}
target = params['_target']
unless target
  puts "Panos task must be run on a proxy"
  exit 1
end

add_plugin_paths(params['_installdir'])


require 'puppet/util/network_device/panos/device'

device = Puppet::Util::NetworkDevice::Panos::Device.new(target)
puts JSON.generate(apikey: device.apikey)
