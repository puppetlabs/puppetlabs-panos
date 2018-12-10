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
require 'puppet/resource_api/transport/wrapper'

params = JSON.parse(ENV['PARAMS'] || STDIN.read)
wrapper = Puppet::ResourceApi::Transport::Wrapper.new('panos', params['credentials_file'])
transport = wrapper.transport

file = params['config_file']
transport.import(file, 'configuration')
if params['apply']
  transport.load_config(File.basename(file))
end
