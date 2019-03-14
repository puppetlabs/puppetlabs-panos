#!/opt/puppetlabs/puppet/bin/ruby

require_relative '../lib/puppet/util/task_helper'
task = Puppet::Util::TaskHelper.new('panos')
result = {}

begin
  file_name = task.params['config_file']
  config = task.transport.show_config

  config.elements.collect('/response/result/config') do |entry| # rubocop:disable Style/CollectionMethods
    config = entry
  end

  File.open(file_name, 'w+') { |file| file.write(config) }
rescue Exception => e # rubocop:disable Lint/RescueException
  result[:_error] = { msg: e.message,
                      kind: 'puppetlabs-panos/unknown',
                      details: {
                        class: e.class.to_s,
                        backtrace: e.backtrace,
                      } }
end

puts result.to_json
