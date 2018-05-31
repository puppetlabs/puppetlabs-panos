require 'net/http'
require 'openssl'
require 'puppet/util/network_device/simple/device'
require 'rexml/document'

module Puppet::Util::NetworkDevice::Panos
  # The main connection class to a PAN-OS API endpoint
  class Device < Puppet::Util::NetworkDevice::Simple::Device
    def facts
      {}
    end

    def config
      raise Puppet::ResourceError, 'Could not find host in the configuration' unless super.key?('host')
      raise Puppet::ResourceError, 'The port attribute in the configuration is not an integer' if super.key?('port') && super['port'] !~ %r{\A[0-9]+\Z}
      raise Puppet::ResourceError, 'Could not find user/password or apikey in the configuration' unless (super.key?('user') && super.key?('password')) || super.key?('apikey')
      super
    end

    def get_config(xpath)
      # https://<firewall>/api/?key=apikey&type=config&action=get&xpath=<path-to-config-node>
      uri = URI::HTTP.build(path: '/api/')
      params = { type: 'config', action: 'get', key: apikey, xpath: xpath }
      uri.query = URI.encode_www_form(params)

      res = http.get(uri)
      unless res.is_a?(Net::HTTPSuccess)
        raise "Error: #{res}"
      end
      doc = REXML::Document.new(res.body)
      doc
    end

    def set_config(xpath, element)
      # https://<firewall>/api/?key=apikey&type=config&action=set&xpath=xpath-value&element=element-value
    end

    def delete_config(xpath)
      # https://<firewall>/api/?key=apikey&type=config&action=delete&xpath=xpath-value
    end

    private

    def http
      host = config['host']
      port = if config.key? 'port'
               config['port'].to_i
             else
               443
             end
      Puppet.debug('Connecting to https://%{host}:%{port}' % { host: host, port: port })
      @http ||= Net::HTTP.start(host, port,
                                use_ssl: true,
                                verify_mode: OpenSSL::SSL::VERIFY_NONE)
    end

    def apikey
      @key ||= if config.key? 'apikey'
                 config['key']
               else
                 get_apikey(config['user'], config['password'])
               end
    end

    def get_apikey(user, password)
      uri = URI::HTTP.build(path: '/api/')
      params = { type: 'keygen', user: user, password: password }
      uri.query = URI.encode_www_form(params)
      Puppet.debug(uri)
      res = http.get(uri)
      unless res.is_a?(Net::HTTPSuccess)
        raise "Error: #{res}: #{res.message}"
      end
      doc = REXML::Document.new(res.body)
      doc.elements['/response/result/key'].text
    end
  end
end
