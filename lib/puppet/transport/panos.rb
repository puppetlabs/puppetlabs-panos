require 'net/http'
require 'openssl'
require 'rexml/document'
require 'securerandom'
require 'cgi'

module Puppet::Transport
  # The main connection class to a PAN-OS API endpoint
  class Panos
    def self.validate_connection_info(connection_info)
      raise Puppet::ResourceError, 'Could not find "user"/"password" or "apikey" in the configuration' unless (connection_info.key?(:user) && connection_info.key?(:password)) || connection_info.key?(:apikey) # rubocop:disable Metrics/LineLength
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
      # https://<firewall>/api/?type=op&cmd=<show><system><info></info></system></show>
      api.request('op', cmd: '<show><system><info/></system></show>')
    end

    def parse_device_facts(response)
      # rubocop:disable Style/StringLiterals
      facts = { "networking" => {} }
      # rubocop:enable Style/StringLiterals

      hostname = response.elements['/response/result/system/hostname'].text
      ip = response.elements['/response/result/system/ip-address'].text
      ip6 = response.elements['/response/result/system/ipv6-address'].text
      mac = response.elements['/response/result/system/mac-address'].text
      model = response.elements['/response/result/system/model'].text
      netmask = response.elements['/response/result/system/netmask'].text
      serial = response.elements['/response/result/system/serial'].text
      uptime = response.elements['/response/result/system/uptime'].text
      version = response.elements['/response/result/system/sw-version'].text
      vsys = response.elements['/response/result/system/multi-vsys'].text

      if hostname
        facts['hostname'] = hostname
        facts['networking']['hostname'] = hostname
      end
      facts['networking']['ip'] = ip if ip
      facts['networking']['ip6'] = ip6 if ip6
      facts['networking']['mac'] = mac if mac
      facts['networking']['netmask'] = netmask if netmask
      facts['operatingsystem'] = model if model
      facts['operatingsystemrelease'] = version if version
      facts['multi-vsys'] = vsys if vsys
      facts['serialnumber'] = serial if serial
      if uptime
        facts['uptime'] = uptime
        facts['system_uptime'] = { 'uptime' => uptime }
      end
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

    def move(xpath, name, dst)
      if dst.empty?
        # perform a check to see if we are already top. PANOS throws an exception if the item is already there
        sibling = get_config(xpath + "/entry[@name='#{name}']/preceding-sibling::entry[1]/@name")
        # https://<firewall>/api/?key=apikey&type=config&action=move&xpath=xpath-value&where=top
        if sibling.elements['/response/result'].attributes.key?('count') &&
           (sibling.elements['/response/result'].attributes['count'].to_i > 0)
          Puppet.debug("moving #{name}")
          api.request('config', action: 'move', xpath: xpath + "/entry[@name='#{name}']", where: 'top')
        end
      else
        Puppet.debug("moving #{name}")
        # https://<firewall>/api/?key=apikey&type=config&action=move&xpath=xpath-value&where=after&dst=<dst>
        api.request('config', action: 'move', xpath: xpath + "/entry[@name='#{name}']", where: 'after', dst: dst)
      end
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

    def apikey
      api.apikey
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
        @password = connection_info[:password].unwrap unless connection_info[:password].nil?
        @ssl_verify = connection_info[:ssl].nil? ? true : connection_info[:ssl]
        @ca_file = connection_info[:ssl_ca_file] if connection_info[:ssl_ca_file]
        @ssl_version = connection_info[:ssl_version] if connection_info[:ssl_version]
        @ciphers = connection_info[:ssl_ciphers] if connection_info[:ssl_ciphers]
        @fingerprint = fingerprint_from_hexdigest(connection_info[:ssl_fingerprint].unwrap) unless connection_info[:ssl_fingerprint].nil?
        @apikey = connection_info[:apikey].unwrap unless connection_info[:apikey].nil?
      end

      # Returns the OpenSSL verify mode based on the verify_mode arguments
      #
      # @raise if verify_mode param is not `on` or `off`
      #
      # @param String verify mode to use
      #
      # @return OpenSSL::SSL verification mode
      def handle_verify_mode(verify_mode)
        case verify_mode
        when true
          OpenSSL::SSL::VERIFY_PEER
        when false
          Puppet.warning("SSL verification turned off in configuration for $#{Puppet[:certname]}")
          OpenSSL::SSL::VERIFY_NONE
        else
          raise Puppet::ResourceError, "\"#{verify_mode}\" is not a valid mode, " \
                'valid modes are: "false" for no client verification, ' \
                'and "true" for validating the certificate'
        end
      end

      # https://stackoverflow.com/questions/22093042/implementing-https-certificate-pubkey-pinning-with-ruby/22108461#22108461
      # this method will be called on the OpenSSL connection
      # to allow for additional verification.
      #
      # A return of false means that verification has failed and
      # will cause certificate verification errors.
      #
      # A return of true is verification has been
      # successful
      def verify_callback(preverify_ok, cert_store)
        # if ssl_fingerprint is specified then do not
        # depend on the pre-verification checks,
        # if no ssl_fingerprint and the preverify_checks fail
        # then certificate verification will fail overall
        return false unless preverify_ok || @fingerprint
        end_cert = cert_store.chain[0]

        return true unless end_cert.to_der == cert_store.current_cert.to_der
        @fingerprint ? same_cert_fingerprint?(end_cert) : true
      end

      def same_cert_fingerprint?(end_cert)
        hexdigest = hexdigest_from_cert(end_cert)
        cert_fingerprint = fingerprint_from_hexdigest(hexdigest)
        cert_fingerprint == @fingerprint
      end

      def hexdigest_from_cert(cert)
        OpenSSL::Digest::SHA256.hexdigest(cert.to_der)
      end

      def fingerprint_from_hexdigest(hexdigest)
        hexdigest.tr(':', '').tr(' ', '').scan(%r{..}).map { |s| s.upcase }.join(':')
      end

      def http
        @http ||= begin
                    Puppet.debug('Connecting to https://%{host}:%{port}' % { host: @host, port: @port })
                    Net::HTTP.start(@host, @port,
                                    use_ssl: true,
                                    verify_mode: handle_verify_mode(@ssl_verify),
                                    ca_file: @ca_file,
                                    ssl_version: @ssl_version,
                                    ciphers: @ciphers ? @ciphers.join(':') : @ciphers,
                                    verify_callback: ->(preverify_ok, cert_store) do
                                                       verify_callback(preverify_ok, cert_store)
                                                     end)
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
