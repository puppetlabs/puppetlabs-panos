#!/opt/puppetlabs/puppet/bin/ruby

require_relative '../lib/puppet/util/task_helper'
task = Puppet::Util::TaskHelper.new('panos')

puts JSON.generate(apikey: task.transport.apikey)
