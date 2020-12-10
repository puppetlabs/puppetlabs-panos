#!/opt/puppetlabs/puppet/bin/ruby
# frozen_string_literal: true

require_relative '../lib/puppet/util/task_helper'
task = Puppet::Util::TaskHelper.new('panos')
result = {}

begin
  file = task.params['config_file']
  task.transport.import(file, 'configuration')

  if task.params['apply']
    task.transport.load_config(File.basename(file))
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
