#!/opt/puppetlabs/puppet/bin/ruby

require_relative '../lib/puppet/util/task_helper'
task = Puppet::Util::TaskHelper.new('panos')
result = {}

begin
  if task.transport.outstanding_changes?
    task.transport.commit
  end
rescue Exception => e # rubocop:disable Lint/RescueException
  result[:_error] = { msg: e.message,
                      kind: 'puppetlabs-panos/unknown',
                      details: {
                        class: e.class.to_s,
                        backtrace: e.backtrace,
                      } }
end

puts result.to_json
