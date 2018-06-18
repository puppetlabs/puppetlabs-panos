require 'net/http'
require 'openssl'
require 'puppet/util/network_device/simple/device'
require 'rexml/document'

module Puppet::Util::NetworkDevice::Panos
  # The main connection class to a PAN-OS API endpoint
  class Device < Puppet::Util::NetworkDevice::Simple::Device
    def facts
      @facts ||= parse_device_facts(fetch_device_facts)
    end

    def config
      raise Puppet::ResourceError, 'Could not find host in the configuration' unless super.key?('host')
      raise Puppet::ResourceError, 'The port attribute in the configuration is not an integer' if super.key?('port') && super['port'] !~ %r{\A[0-9]+\Z}
      raise Puppet::ResourceError, 'Could not find user/password or apikey in the configuration' unless (super.key?('user') && super.key?('password')) || super.key?('apikey')
      super
    end

    def apikey
      @key ||= if config.key? 'apikey'
                 config['apikey']
               else
                 get_apikey(config['user'], config['password'])
               end
    end

    def fetch_device_facts
      Puppet.debug('Retreiving PANOS Device Facts')
      # https://<firewall>/api/?key=apikey&type=version
      api_request('version')
    end

    def parse_device_facts(response)
      facts = {}

      model = response.elements['/response/result/model'].text
      version = response.elements['/response/result/sw-version'].text
      vsys = response.elements['/response/result/multi-vsys'].text

      facts['operatingsystem'] = model if model
      facts['operatingsystemrelease'] = version if version
      facts['multi-vsys'] = vsys if vsys
      facts
    end

    def get_config(xpath)
      Puppet.debug("Retrieving #{xpath}")
      # https://<firewall>/api/?key=apikey&type=config&action=get&xpath=<path-to-config-node>
      api_request('config', action: 'get', xpath: xpath)
    end

    def set_config(xpath, document)
      Puppet.debug("Writing to #{xpath}")
      # https://<firewall>/api/?key=apikey&type=config&action=set&xpath=xpath-value&element=element-value
      api_request('config', action: 'set', xpath: xpath, element: document.to_s)
    end

    def edit_config(xpath, document)
      Puppet.debug("Updating #{xpath}")
      # https://<firewall>/api/?key=apikey&type=config&action=edit&xpath=xpath-value&element=element-value
      api_request('config', action: 'edit', xpath: xpath, element: document.to_s)
    end

    def delete_config(xpath)
      Puppet.debug("Deleting #{xpath}")
      # https://<firewall>/api/?key=apikey&type=config&action=delete&xpath=xpath-value
      api_request('config', action: 'delete', xpath: xpath)
    end

    def outstanding_changes?
      # /api/?type=op&cmd=<check><pending-changes></pending-changes></check>
      result = api_request('op', cmd: '<check><pending-changes></pending-changes></check>')
      result.elements['/response/result'].text == 'yes'
    end

    def validate
      Puppet.debug('Validating configuration')
      # https://<firewall>/api/?type=op&cmd=<validate><full></full></validate>
      job_request('op', cmd: '<validate><full></full></validate>')
    end

    def commit
      Puppet.debug('Committing outstanding changes')
      # https://<firewall>/api/?type=commit&cmd=<commit></commit>
      job_request('commit', cmd: '<commit></commit>')
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

    def api_request(type, **options)
      params = { type: type, key: apikey }
      params.merge!(options)

      uri = URI::HTTP.build(path: '/api/')
      uri.query = URI.encode_www_form(params)

      res = http.get(uri)
      unless res.is_a?(Net::HTTPSuccess)
        raise "Error: #{res}: #{res.message}"
      end
      doc = REXML::Document.new(res.body)
      handle_response_errors(doc) unless res.is_a?(Net::HTTPSuccess)
      doc
    end

    def job_request(type, **options)
      result = api_request(type, options)
      response_message = result.elements['/response/msg']
      if response_message
        Puppet.debug('api response (no changes): %{msg}' % { msg: response_message.text })
        return
      end

      job_id = result.elements['/response/result/job'].text
      job_msg = []
      result.elements['/response/result/msg'].each_element_with_text { |e| job_msg << e.text }
      Puppet.debug('api response (job queued): %{msg}' % { msg: job_msg.join("\n") })

      tries = 0
      loop do
        # https://<firewall>/api/?type=op&cmd=<show><jobs><id>4</id></jobs></show>
        poll_result = api_request('op', cmd: "<show><jobs><id>#{job_id}</id></jobs></show>")
        status = poll_result.elements['/response/result/job/status'].text
        result = poll_result.elements['/response/result/job/result'].text
        progress = poll_result.elements['/response/result/job/progress'].text
        details = []
        poll_result.elements['/response/result/job/details'].each_element_with_text { |e| details << e.text }
        if status == 'FIN'
          # TODO: go to debug
          # poll_result.write($stdout, 2)
          break if result == 'OK'
          raise Puppet::ResourceError, 'job failed. result="%{result}": %{details}' % { result: result, details: details.join("\n") }
        end
        tries += 1

        details.unshift("sleeping for #{tries} seconds")
        Puppet.debug('job still in progress (%{progress}%%). result="%{result}": %{details}' % { result: result, progress: progress, details: details.join("\n") })
        sleep tries
      end

      Puppet.debug('job was successful')
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
      handle_response_errors(doc)
      doc.elements['/response/result/key'].text
    end

    def message_from_code(code)
      case code
      when '1'
        'Unkown command: The specific config or operational command is not recognized.'
      when '2', '3', '4', '5', '11', '21'
        "Internal error: Check with Palo Alto's technical support."
      when '6'
        'Bad XPath: The xpath specified in one or more attributes of the command is invalid.'
      when '7'
        "Object not present: Object specified by the xpath is not present. For example, entry[@name='value'] where no object with name 'value' is present."
      when '8'
        'Object not unique: For commands that operate on a single object, the specified object is not unique.'
      when '10'
        'Reference count not zero: Object cannot be deleted as there are other objects that refer to it. For example, address object still in use in policy.'
      when '12'
        'Invalid object: Xpath or element values provided are not complete.'
      when '14'
        'Operation not possible: Operation is allowed but not possible in this case. For example, moving a rule up one position when it is already at the top.'
      when '15'
        'Operation denied: Operation is allowed. For example, Admin not allowed to delete own account, Running a command that is not allowed on a passive device.'
      when '16'
        'Unauthorized: The API role does not have access rights to run this query.'
      when '17'
        'Invalid command: Invalid command or parameters.'
      when '18'
        'Malformed command: The XML is malformed.'
      when '19', '20'
        'Success: Command completed successfully.'
      when '22'
        'Session timed out: The session for this query timed out.'
      else
        'Unknown error code %{code}' % { code: code }
      end
    end

    def handle_response_errors(doc)
      status = doc.elements['/response'].attributes['status']
      code = doc.elements['/response'].attributes['code']
      error_message = ('Received "%{status}" with code %{code}: %{message}' % {
        status: status,
        code: code,
        message: message_from_code(code),
      })
      # require 'pry';binding.pry
      if status == 'success'
        # Messages without a code require more processing by the caller
        Puppet.debug(error_message) if code
      else
        error_message << "\n"
        doc.write(error_message, 2)
        raise Puppet::ResourceError, error_message
      end
    end
  end
end
