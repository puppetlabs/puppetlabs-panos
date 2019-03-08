#!/opt/puppetlabs/puppet/bin/ruby

require_relative '../lib/puppet/util/task_helper'
task = Puppet::Util::TaskHelper.new('panos')

file = task.params['config_file']
transport.import(file, 'configuration')

if task.params['apply']
  transport.load_config(File.basename(file))
end
