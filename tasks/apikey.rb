#!/opt/puppetlabs/puppet/bin/ruby

require_relative 'panos_task'
task = PanosTask.new

puts JSON.generate(apikey: task.transport.apikey)
