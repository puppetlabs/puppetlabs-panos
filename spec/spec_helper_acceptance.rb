require 'json'
require 'net/http'
require 'open3'
require 'fileutils'

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

    # workaround for https://tickets.puppetlabs.com/browse/PUP-9104
    c.before :each do
      cache = File.expand_path('~/.puppetlabs/opt/puppet/cache/devices/sut/')
      if File.directory?(cache)
        FileUtils.rm_rf(cache)
      end
    end

    puts "Detected #{@platform} config for #{@hostname}"

    File.open('spec/fixtures/acceptance-credentials.conf', 'w') do |file|
      file.puts <<CREDENTIALS
host: #{@hostname}
user: #{ENV['PANOS_TEST_USER'] || 'admin'}
password: #{ENV['PANOS_TEST_PASSWORD'] || 'admin'}
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
    next if !@destroy || ENV['BEAKER_destroy'] == 'no' # TODO: handle 'onpass'

    vmpooler = Net::HTTP.start(ENV['VMPOOLER_HOST'] || 'vmpooler.delivery.puppetlabs.net')
    reply = vmpooler.delete("/api/v1/vm/#{@hostname}")
    raise "Error: #{reply}: #{reply.message}" unless reply.is_a?(Net::HTTPSuccess)

    data = JSON.parse(reply.body)
    raise "VMPooler is not ok: #{data.inspect}" unless data['ok'] == true

    puts "#{@hostname} scheduled for recycling"
  end
end
