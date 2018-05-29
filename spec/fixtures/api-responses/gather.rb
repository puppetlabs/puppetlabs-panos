#!/usr/bin/env ruby

require 'net/http'
require 'rexml/document'
require 'openssl'

uri = URI::HTTP.build(host: ARGV[0], path: '/api/')
uri.scheme = 'https'
uri.port = 443

def keygen(http, user, password)
  uri = URI::HTTP.build(path: '/api/')
  params = { type: 'keygen', user: user, password: password }
  uri.query = URI.encode_www_form(params)
  res = http.get(uri)
  unless res.is_a?(Net::HTTPSuccess)
    raise "Error: #{res}"
  end
  doc = REXML::Document.new(res.body)
  doc.elements['/response/result/key'].text
end

def get(http, key, xpath)
  uri = URI::HTTP.build(path: '/api/')
  params = { type: 'config', action: 'get', key: key, xpath: xpath }
  uri.query = URI.encode_www_form(params)

  res = http.get(uri)
  unless res.is_a?(Net::HTTPSuccess)
    raise "Error: #{res}"
  end
  doc = REXML::Document.new(res.body)
  doc
end

Net::HTTP.start(
  uri.hostname,
  uri.port,
  use_ssl: true,
  verify_mode: OpenSSL::SSL::VERIFY_NONE,
) do |http|
  puts 'Running unverified SSL'

  key = keygen(http, ARGV[1], ARGV[2])
  # puts key

  ['deviceconfig', 'network', 'platform', 'vsys'].each do |subpath|
    doc = get(http, key, "/config/devices/entry/#{subpath}")
    File.open("spec/fixtures/api-responses/vm1-8.1/#{subpath}.xml", 'w') do |f|
      doc.write(f, -1)
    end
  end

  doc = get(http, key, '/config/mgt-config')
  File.open('spec/fixtures/api-responses/vm1-8.1/mgt-config.xml', 'w') do |f|
    doc.write(f, -1)
  end
end
