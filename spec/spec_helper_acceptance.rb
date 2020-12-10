# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'net/http'
require 'open3'

module Helpers
  def debug_output?
    ENV['PANOS_TEST_DEBUG'] == 'true' || ENV['BEAKER_debug'] == 'true'
  end
end

RSpec.configure do |c|
  c.include Helpers
  c.extend Helpers

  c.before :suite do
    system('rake spec_prep')
    # system('env|sort')
    if ENV['PANOS_TEST_HOST']
      @platform = ENV['PANOS_TEST_PLATFORM']
      @hostname = ENV['PANOS_TEST_HOST']
    elsif ENV['ABS_RESOURCE_HOSTS']
      puts "Using preconfigured ABS_RESOURCE_HOSTS: #{ENV['ABS_RESOURCE_HOSTS']}"
      hosts = JSON.parse(ENV['ABS_RESOURCE_HOSTS'])
      @platform = hosts[0]['type']
      @hostname = hosts[0]['hostname']
      @destroy = false
    elsif ENV['PANOS_TEST_PLATFORM']
      puts "Using VMPooler for PANOS_TEST_PLATFORM: #{ENV['PANOS_TEST_PLATFORM']}"
      @platform = ENV['PANOS_TEST_PLATFORM']

      vmpooler = Net::HTTP.start(ENV['VMPOOLER_HOST'] || 'vmpooler.delivery.puppetlabs.net')

      reply = vmpooler.post("/api/v1/vm/#{@platform}", '')
      raise "Error: #{reply}: #{reply.message}" unless reply.is_a?(Net::HTTPSuccess)

      data = JSON.parse(reply.body)
      raise "VMPooler is not ok: #{data.inspect}" unless data['ok'] == true

      @hostname = "#{data[@platform]['hostname']}.#{data['domain']}"
      puts "reserved #{@hostname} in vmpooler"
      @destroy = true
    else
      raise 'Could not locate or create a test host'
    end

    puts "Detected #{@platform} config for #{@hostname}"

    c.add_setting :host, default: @hostname
    c.add_setting :user, default: (ENV['PANOS_TEST_USER'] || 'admin')
    c.add_setting :password, default: (ENV['PANOS_TEST_PASSWORD'] || 'admin')

    File.open('spec/fixtures/acceptance-credentials.conf', 'w') do |file|
      file.puts <<CREDENTIALS
host: #{RSpec.configuration.host}
user: #{RSpec.configuration.user}
password: #{RSpec.configuration.password}
ssl: false
CREDENTIALS
    end

    File.open('spec/fixtures/acceptance-device.conf', 'w') do |file|
      file.puts <<DEVICE
[sut]
type panos
url file://#{Dir.getwd}/spec/fixtures/acceptance-credentials.conf
DEVICE
    end
  end

  c.after :suite do
    FileUtils.rm(Dir.glob('spec/fixtures/config-*.xml'))

    next if !@destroy || ENV['BEAKER_destroy'] == 'no' # TODO: handle 'onpass'

    vmpooler = Net::HTTP.start(ENV['VMPOOLER_HOST'] || 'vmpooler.delivery.puppetlabs.net')
    reply = vmpooler.delete("/api/v1/vm/#{@hostname}")
    raise "Error: #{reply}: #{reply.message}" unless reply.is_a?(Net::HTTPSuccess)

    data = JSON.parse(reply.body)
    raise "VMPooler is not ok: #{data.inspect}" unless data['ok'] == true

    puts "#{@hostname} scheduled for recycling"
  end
end
