#!/opt/puppetlabs/puppet/bin/ruby

require_relative 'panos_task'
task = PanosTask.new

if task.transport.outstanding_changes?
  task.transport.commit
end
