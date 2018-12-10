require 'net/http'
require 'openssl'
require 'rexml/document'
require 'securerandom'
require 'cgi'

module Puppet::Transport
  # The main connection class to a PAN-OS API endpoint
  class Panos
    def self.validate_connection_info(connection_info)
      raise Puppet::ResourceError, 'Could not find "username"/"password" or "apikey" in the configuration' unless (connection_info.key?(:username) && connection_info.key?(:password)) || connection_info.key?(:apikey) # rubocop:disable Metrics/LineLength
      connection_info
    end

    # attr_reader :config

    def initialize(_context, connection_info)
      @connection_info = self.class.validate_connection_info(connection_info)
    end

    def facts(context)
      @facts ||= parse_device_facts(fetch_device_facts(context))
    end

    def fetch_device_facts(context)
      context.debug('Retrieving PANOS Device Facts')
      # https://<firewall>/api/?key=apikey&type=version
      api.request('version')
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
      api.request('config', action: 'get', xpath: xpath)
    end

    def set_config(xpath, document)
      Puppet.debug("Writing to #{xpath}")
      # https://<firewall>/api/?key=apikey&type=config&action=set&xpath=xpath-value&element=element-value
      api.request('config', action: 'set', xpath: xpath, element: document)
    end

    def edit_config(xpath, document)
      Puppet.debug("Updating #{xpath}")
      # https://<firewall>/api/?key=apikey&type=config&action=edit&xpath=xpath-value&element=element-value
      api.request('config', action: 'edit', xpath: xpath, element: document)
    end

    def delete_config(xpath)
      Puppet.debug("Deleting #{xpath}")
      # https://<firewall>/api/?key=apikey&type=config&action=delete&xpath=xpath-value
      api.request('config', action: 'delete', xpath: xpath)
    end

    def import(file_path, category)
      Puppet.debug("Importing #{category}")
      # https://<firewall>/api/?key=apikey&type=import&category=category
      # POST: File(file_path)
      api.upload('import', file_path, category: category)
    end

    def load_config(file_name)
      Puppet.debug('Loading Config')
      # https://<firewall>/api/?type=op&cmd=<load><config><from>file_name</from></config></load>
      api.request('op', cmd: "<load><config><from>#{file_name}</from></config></load>")
    end

    def show_config
      Puppet.debug('Retrieving Config')
      # https://<firewall>/api/?type=op&cmd=<show><config><running></running></config></show>
      api.request('op', cmd: '<show><config><running></running></config></show>')
    end

    def outstanding_changes?
      # /api/?type=op&cmd=<check><pending-changes></pending-changes></check>
      result = api.request('op', cmd: '<check><pending-changes></pending-changes></check>')
      result.elements['/response/result'].text == 'yes'
    end

    def validate
      Puppet.debug('Validating configuration')
      # https://<firewall>/api/?type=op&cmd=<validate><full></full></validate>
      api.job_request('op', cmd: '<validate><full></full></validate>')
    end

    def commit
      Puppet.debug('Committing outstanding changes')
      # https://<firewall>/api/?type=commit&cmd=<commit></commit>
      api.job_request('commit', cmd: '<commit></commit>')
    end

    private

    def api
      @api ||= API.new(@connection_info)
    end

    # A simple adaptor to expose the basic PAN-OS XML API operations.
    # Having this in a separate class aids with keeping the gnarly HTTP code
    # away from the business logic, and helps with testing, too.
    # @api private
    class API
      def initialize(connection_info)
        @host = connection_info[:host] || connection_info[:address]
        @port = connection_info.key?(:port) ? connection_info[:port].to_i : 443
        @user = connection_info[:user] || connection_info[:username]
        @password = connection_info[:password]
        @apikey = connection_info[:apikey]
      end

      def http
        @http ||= begin
                    Puppet.debug('Connecting to https://%{host}:%{port}' % { host: @host, port: @port })
                    Net::HTTP.start(@host, @port,
                                    use_ssl: true,
                                    verify_mode: OpenSSL::SSL::VERIFY_NONE)
                  end
      end

      def fetch_apikey(user, password)
        uri = URI::HTTP.build(path: '/api/')
        params = { type: 'keygen', user: user, password: password }
        uri.query = URI.encode_www_form(params)

        res = http.get(uri)
        unless res.is_a?(Net::HTTPSuccess)
          raise "Error: #{res}: #{res.message}"
        end
        doc = REXML::Document.new(res.body)
        handle_response_errors(doc)
        doc.elements['/response/result/key'].text
      end

      def apikey
        @apikey ||= fetch_apikey(@user, @password)
      end

      def request(type, **options)
        params = { type: type, key: apikey }
        params.merge!(options)

        uri = URI::HTTP.build(path: '/api/')
        uri.query = URI.encode_www_form(params)

        res = http.get(uri)
        unless res.is_a?(Net::HTTPSuccess)
          raise "Error: #{res}: #{res.message}"
        end
        doc = REXML::Document.new(res.body)
        handle_response_errors(doc)
        doc
      end

      def upload(type, file, **options)
        params = { type: type, key: apikey }
        params.merge!(options)

        uri = URI::HTTP.build(path: '/api/')
        uri.query = URI.encode_www_form(params)

        raise Puppet::ResourceError, "File: `#{file}` does not exist" unless File.exist?(file)

        # from: http://www.rubyinside.com/nethttp-cheat-sheet-2940.html
        # Token used to terminate the file in the post body.
        @boundary ||= SecureRandom.hex(25)

        post_body = []
        post_body << "--#{@boundary}\r\n"
        post_body << "Content-Disposition: form-data; name=\"file\"; filename=\"#{CGI.escape(File.basename(file))}\"\r\n"
        post_body << "Content-Type: text/plain\r\n"
        post_body << "\r\n"
        post_body << File.open(file, 'rb') { |f| f.read }
        post_body << "\r\n--#{@boundary}--\r\n"

        request = Net::HTTP::Post.new(uri.request_uri)
        request.body = post_body.join
        request.content_type = "multipart/form-data, boundary=#{@boundary}"

        res = http.request(request)
        unless res.is_a?(Net::HTTPSuccess)
          raise "Error: #{res}: #{res.message}"
        end
        doc = REXML::Document.new(res.body)
        handle_response_errors(doc)
        doc
      end

      def job_request(type, **options)
        result = request(type, options)
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
          poll_result = request('op', cmd: "<show><jobs><id>#{job_id}</id></jobs></show>")
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

      def message_from_code(code)
        message_codes ||= begin
          h = Hash.new { |_hash, key| 'Unknown error code %{code}' % { code: key } }
          h['1'] = 'Unknown command: The specific config or operational command is not recognized.'
          h['2'] = "Internal error: Check with Palo Alto's technical support."
          h['3'] = "Internal error: Check with Palo Alto's technical support."
          h['4'] = "Internal error: Check with Palo Alto's technical support."
          h['5'] = "Internal error: Check with Palo Alto's technical support."
          h['11'] = "Internal error: Check with Palo Alto's technical support."
          h['21'] = "Internal error: Check with Palo Alto's technical support."
          h['6'] = 'Bad XPath: The xpath specified in one or more attributes of the command is invalid.'
          h['7'] = "Object not present: Object specified by the xpath is not present. For example, entry[@name='value'] where no object with name 'value' is present."
          h['8'] = 'Object not unique: For commands that operate on a single object, the specified object is not unique.'
          h['10'] = 'Reference count not zero: Object cannot be deleted as there are other objects that refer to it. For example,:addressobject still in use in policy.'
          h['12'] = 'Invalid object: Xpath or element values provided are not complete.'
          h['14'] = 'Operation not possible: Operation is allowed but not possible in this case. For example, moving a rule up one position when it is already at the top.'
          h['15'] = 'Operation denied: Operation is allowed. For example, Admin not allowed to delete own account, Running a command that is not allowed on a passive device.'
          h['16'] = 'Unauthorized: The API role does not have access rights to run this query.'
          h['17'] = 'Invalid command: Invalid command or parameters.'
          h['18'] = 'Malformed command: The XML is malformed.'
          h['19'] = 'Success: Command completed successfully.'
          h['20'] = 'Success: Command completed successfully.'
          h['22'] = 'Session timed out: The session for this query timed out.'
          h
        end
        message_codes[code]
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
end
