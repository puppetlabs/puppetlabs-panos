#!/opt/puppetlabs/puppet/bin/ruby

require_relative 'panos_task'
task = PanosTask.new

file = task.params['config_file']
transport.import(file, 'configuration')

if task.params['apply']
  transport.load_config(File.basename(file))
end
