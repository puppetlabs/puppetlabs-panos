#!/opt/puppetlabs/puppet/bin/ruby

require_relative '../lib/puppet/util/task_helper'
task = Puppet::Util::TaskHelper.new('panos')

if task.transport.outstanding_changes?
  task.transport.commit
end
