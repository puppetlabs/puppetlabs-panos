require 'spec_helper'
require 'puppet/transport/panos'
require 'puppet/resource_api'
require 'support/matchers/have_xml'

RSpec.describe Puppet::Transport do
  describe Puppet::Transport::Panos do
    let(:transport) { described_class.new(context, connection_info) }
    let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
    let(:pass) { Puppet::Pops::Types::PSensitiveType::Sensitive.new('password') }
    let(:fingerprint) { Puppet::Pops::Types::PSensitiveType::Sensitive.new('fingerprint') }
    let(:apikey) { Puppet::Pops::Types::PSensitiveType::Sensitive.new('APIKEY') }
    let(:connection_info) do
      {
        host: 'www.example.com',
        user: 'admin',
        password: pass,
        ssl: true,
        ssl_fingerprint: fingerprint,
        ssl_ca_file: 'bar/foo',
        ssl_version: 'TLSv1',
        ssl_ciphers: ['abc', 'def', 'xyz'],
      }
    end
    let(:api) { instance_double('Puppet::Transport::Panos::API', 'api') }
    let(:xml_doc) { REXML::Document.new(device_response) }
    let(:device_response) do
      '<response status="success">
        <result>
          <system>
            <hostname>PA-VM</hostname>
            <ip-address>192.168.122.254</ip-address>
            <public-ip-address>unknown</public-ip-address>
            <netmask>255.255.255.0</netmask>
            <default-gateway>192.168.122.1</default-gateway>
            <is-dhcp>yes</is-dhcp>
            <ipv6-address>fd03:a7d:d814:8389:1:2:3:4</ipv6-address>
            <ipv6-link-local-address>fe80::5054:ff:fe68:eb58/64</ipv6-link-local-address><ipv6-default-gateway/>
            <mac-address>52:54:00:68:eb:58</mac-address>
            <time>Tue May 28 15:35:35 2019
            </time>
            <uptime>0 days, 7:36:01</uptime>
            <devicename>PA-VM</devicename>
            <family>vm</family>
            <model>PA-VM</model>
            <serial>123456</serial>
            <vm-mac-base>BA:DB:EE:FB:AD:00</vm-mac-base>
            <vm-mac-count>255</vm-mac-count>
            <vm-uuid>70602111-DCA5-49CF-A677-9E663B693DE2</vm-uuid>
            <vm-cpuid>KVM:E3060500FFFB8B0F</vm-cpuid>
            <vm-license>none</vm-license>
            <vm-mode>KVM</vm-mode>
            <cloud-mode>non-cloud</cloud-mode>
            <sw-version>8.1.3</sw-version>
            <global-protect-client-package-version>0.0.0</global-protect-client-package-version>
            <app-version>769-4439</app-version>
            <app-release-date/>
            <av-version>0</av-version>
            <av-release-date/>
            <threat-version>0</threat-version>
            <threat-release-date/>
            <wf-private-version>0</wf-private-version>
            <wf-private-release-date>unknown</wf-private-release-date>
            <url-db>paloaltonetworks</url-db>
            <wildfire-version>0</wildfire-version>
            <wildfire-release-date/>
            <url-filtering-version>0000.00.00.000</url-filtering-version>
            <global-protect-datafile-version>unknown</global-protect-datafile-version>
            <global-protect-datafile-release-date>unknown</global-protect-datafile-release-date>
            <global-protect-clientless-vpn-version>0</global-protect-clientless-vpn-version>
            <global-protect-clientless-vpn-release-date/>
            <logdb-version>8.1.8</logdb-version>
            <platform-family>vm</platform-family>
            <vpn-disable-mode>off</vpn-disable-mode>
            <multi-vsys>off</multi-vsys>
            <operational-mode>normal</operational-mode>
          </system>
        </result>
      </response>'
    end
    let(:fact_hash) do
      {
        'networking' => {
          'hostname' => 'PA-VM',
          'ip' => '192.168.122.254',
          'ip6' => 'fd03:a7d:d814:8389:1:2:3:4',
          'mac' => '52:54:00:68:eb:58',
          'netmask' => '255.255.255.0',
        },
        'hostname' => 'PA-VM',
        'operatingsystem' => 'PA-VM',
        'operatingsystemrelease' => '8.1.3',
        'multi-vsys' => 'off',
        'serialnumber' => '123456',
        'uptime' => '0 days, 7:36:01',
        'system_uptime' => {
          'uptime' => '0 days, 7:36:01',
        },
      }
    end

    before(:each) do
      allow(context).to receive(:debug)
    end

    it 'parses facts correctly' do
      expect(transport.parse_device_facts(xml_doc)).to eq(fact_hash)
    end

    describe '#new' do
      # TODO: validation functionality should be tested in puppet-resource_api, not here
      let(:transport) { Puppet::ResourceApi::Transport.connect('panos', connection_info) }

      context 'when host is not provided' do
        let(:connection_info) { { user: 'admin', password: 'password' } }

        it { expect { transport }.to raise_error Puppet::ResourceError, %r{The following mandatory attributes were not provided:.*host}m }
      end
      context 'when port is provided but not valid' do
        let(:connection_info) { { host: 'www.example.com', port: 'foo', user: 'admin', password: 'password' } }

        # TODO: rsapi should be checking this and raising an error
        pending { expect { transport }.to raise_error Puppet::ResourceError, 'The port attribute in the configuration is not an integer' }
      end
      context 'when valid user credentials are not provided' do
        [
          { host: 'www.example.com', user: 'admin' },
          { host: 'www.example.com', password: 'password' },
          { host: 'www.example.com' },
        ].each do |config|
          let(:connection_info) { config }

          it { expect { transport }.to raise_error Puppet::ResourceError, 'Could not find "user"/"password" or "apikey" in the configuration' }
        end
      end
      context 'when apikey is provided' do
        let(:connection_info) { { host: 'www.example.com', apikey: 'APIKEY' } }

        it { expect { transport }.not_to raise_error Puppet::ResourceError }
      end
      context 'when correct credentials are provided' do
        let(:connection_info) { { host: 'www.example.com', user: 'foo', password: 'password' } }

        it { expect { transport }.not_to raise_error Puppet::ResourceError }
      end
    end

    context 'with the internal api mocked' do
      before(:each) do
        allow(transport).to receive(:api).with(no_args).and_return(api)
      end

      describe '#facts' do
        context 'when the response returns valid data' do
          it 'parses device facts' do
            expect(api).to receive(:request).with('op', cmd: '<show><system><info/></system></show>').and_return(REXML::Document.new(device_response))
            expect(transport.facts(context)).to eq(fact_hash)
          end
        end
      end

      describe 'helper functions' do
        let(:xpath) { '/some/xpath' }
        let(:document) { '<xml>test</xml>' }

        it '#get_config(xpath)' do
          expect(api).to receive(:request).with('config', action: 'get', xpath: xpath)
          transport.get_config(xpath)
        end

        it '#set_config(xpath, document)' do
          expect(api).to receive(:request).with('config', action: 'set', xpath: xpath, element: document)
          transport.set_config(xpath, document)
        end

        it '#edit_config(xpath, document)' do
          expect(api).to receive(:request).with('config', action: 'edit', xpath: xpath, element: document)
          transport.edit_config(xpath, document)
        end

        it '#delete_config(xpath)' do
          expect(api).to receive(:request).with('config', action: 'delete', xpath: xpath)
          transport.delete_config(xpath)
        end
      end

      describe '#import(file_path, category)' do
        let(:file_path) { '/some/file/path/file.txt' }
        let(:category) { 'foo' }

        it 'calls the api correctly' do
          expect(api).to receive(:upload).with('import', file_path, category: category)
          transport.import(file_path, category)
        end
      end

      describe '#load_config(file_name)' do
        let(:file_name) { 'file.txt' }

        it 'calls the api correctly' do
          expect(api).to receive(:request).with('op', cmd: %r{#{file_name}})
          transport.load_config(file_name)
        end
      end

      describe '#show_config' do
        it 'calls the api correctly' do
          expect(api).to receive(:request).with('op', cmd: '<show><config><running></running></config></show>')
          transport.show_config
        end
      end

      describe '#outstanding_changes?' do
        context 'when there are outstanding changes' do
          let(:xml_response) { REXML::Document.new('<response><result>yes</result></response>') }

          it {
            expect(api).to receive(:request).with('op', anything).and_return(xml_response)
            expect(transport).to be_outstanding_changes
          }
        end
        context 'when there are no outstanding changes' do
          let(:xml_response) { REXML::Document.new('<response><result>no</result></response>') }

          it {
            expect(api).to receive(:request).with('op', anything).and_return(xml_response)
            expect(transport).not_to be_outstanding_changes
          }
        end
      end

      describe '#validate' do
        it 'calls the api correctly' do
          expect(api).to receive(:job_request).with('op', anything)
          transport.validate
        end
      end

      describe '#commit' do
        it 'calls the api correctly' do
          expect(api).to receive(:job_request).with('commit', anything)
          transport.commit
        end
      end

      describe '#apikey' do
        it 'calls the api correctly' do
          expect(api).to receive(:apikey)
          transport.apikey
        end
      end
    end

    context 'without the internal api mocked' do
      it 'makes a webcall' do
        stub_request(:get, 'https://www.example.com/api/?password=password&type=keygen&user=admin')
          .to_return(status: 200, body: "<response status='success'><result><key>SOMEKEY</key></result></response>")

        stub_request(:get, 'https://www.example.com/api/?cmd=%3Cshow%3E%3Csystem%3E%3Cinfo/%3E%3C/system%3E%3C/show%3E&key=SOMEKEY&type=op')
          .to_return(status: 200, body: device_response)

        expect(transport.facts(context)).to eq(fact_hash)
      end
    end
  end

  describe Puppet::Transport::Panos::API do
    subject(:instance) { described_class.new(credentials) }

    let(:pass) { Puppet::Pops::Types::PSensitiveType::Sensitive.new('password') }
    let(:apikey) { Puppet::Pops::Types::PSensitiveType::Sensitive.new('APIKEY') }

    let(:credentials) { { host: 'www.example.com' } }

    def stub_keygen_request(**options)
      stub_request(:get, 'https://www.example.com/api/?password=password&type=keygen&user=user')
        .to_return(options)
    end

    def stub_api_request(**options)
      stub_request(:get, 'https://www.example.com/api/?type=THETYPE&key=APIKEY&option_a=ANOPTION')
        .to_return(options)
    end

    def stub_upload_request(**options)
      stub_request(:post, 'https://www.example.com/api/?key=APIKEY&type=THETYPE&category=CATEGORY')
        .to_return(options)
      # Error: "WebMock does not support matching body for multipart/form-data requests yet"
      # .with(body: /filename=\"#{file_name}\".*#{Regexp.escape(file_content)}/m,
      #       headers: {
      #         'Content-Type' => /multipart\/form-data/
      #       })
    end

    describe '#fetch_apikey(user, password)' do
      context 'with valid user and password' do
        it 'fetches the API key' do
          stub_keygen_request(status: 200, body: "<response status='success'><result><key>SOMEKEY</key></result></response>")

          expect(instance.fetch_apikey('user', 'password')).to eq 'SOMEKEY'

          expect(a_request(:get, 'https://www.example.com/api/?password=password&type=keygen&user=user')).to have_been_made.once
        end
      end

      context 'with invalid user and password' do
        it 'raises a helpful error' do
          stub_keygen_request(status: 403)

          expect { instance.fetch_apikey('user', 'password') }.to raise_error RuntimeError, %r{forbidden}i

          expect(a_request(:get, 'https://www.example.com/api/?password=password&type=keygen&user=user')).to have_been_made.once
        end
      end
    end

    describe '#apikey' do
      let(:credentials) { super().merge(user: 'user', password: pass) }

      it 'makes only a single HTTP call' do
        stub_keygen_request(status: 200, body: "<response status = 'success'><result><key>SOMEKEY</key></result></response>")

        expect(instance.apikey).to eq 'SOMEKEY'
        expect(instance.apikey).to eq 'SOMEKEY'

        expect(a_request(:get, 'https://www.example.com/api/?password=password&type=keygen&user=user')).to have_been_made.once
      end
    end

    describe '#upload(file_name, file_content, **options)' do
      let(:credentials) { super().merge(apikey: apikey) }
      let(:doc) { instance.upload('THETYPE', '/path/to/file/test.txt', category: 'CATEGORY') }
      let(:file_content) { '<test>some config info</test>' }

      before(:each) do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:open).and_return(file_content)
      end

      context 'when the API returns success' do
        before(:each) do
          stub_upload_request(status: 200, body: "<response status='success'><msg><line>test.txt saved</line></msg></response>")
        end

        it {
          doc
          expect(a_request(:post, 'https://www.example.com/api/?key=APIKEY&type=THETYPE&category=CATEGORY')).to have_been_made.once
        }
        it { expect(doc).to be_a REXML::Document }
        it { expect(doc).to have_xml('response[@status="success"]') }
      end

      context 'when the file provided does not exist' do
        it do
          allow(File).to receive(:exist?).and_return(false)
          expect { doc }.to raise_error Puppet::ResourceError, 'File: `/path/to/file/test.txt` does not exist'
        end
      end

      context 'when the API returns an HTTP error' do
        it do
          stub_upload_request(status: 400, body: "<response status='error' code='400'><result><msg>TESTMESSAGE.</msg></result></response>")

          expect { doc }.to raise_error RuntimeError, %r{HTTPBadRequest}
        end
      end
      context 'when the API returns a semantic error' do
        it do
          stub_upload_request(status: 200, body: "<response status='error' code='18'><msg><line>Malformed Request</line></msg></response>")

          expect { doc }.to raise_error Puppet::ResourceError, %r{Malformed Request}
        end
      end
    end

    describe '#request(type, **options)' do
      let(:credentials) { super().merge(apikey: apikey) }
      let(:doc) { instance.request('THETYPE', option_a: 'ANOPTION') }

      context 'when the API returns success' do
        before(:each) do
          stub_api_request(status: 200, body: "<response status='success' code='19'></response>")
        end

        it {
          doc
          expect(a_request(:get, 'https://www.example.com/api/?type=THETYPE&key=APIKEY&option_a=ANOPTION')).to have_been_made.once
        }
        it { expect(doc).to be_a REXML::Document }
        it { expect(doc).to have_xml('response[@status="success"]') }
      end

      context 'when the API returns an HTTP error' do
        it do
          stub_api_request(status: 400, body: "<response status='error' code='400'><result><msg>TESTMESSAGE.</msg></result></response>")

          expect { doc }.to raise_error RuntimeError, %r{HTTPBadRequest}
        end
      end
      context 'when the API returns a semantic error' do
        it do
          stub_api_request(status: 200, body: "<response status='error' code='18'><msg><line>Malformed Request</line></msg></response>")

          expect { doc }.to raise_error Puppet::ResourceError, %r{Malformed Request}
        end
      end
    end

    describe '#handle_verify_mode' do
      context 'when ssl mode is `false`' do
        let(:verify_mode) { instance.handle_verify_mode(false) }

        it { expect(verify_mode).to equal OpenSSL::SSL::VERIFY_NONE }
      end
      context 'when ssl mode is true' do
        let(:verify_mode) { instance.handle_verify_mode(true) }

        it { expect(verify_mode).to equal OpenSSL::SSL::VERIFY_PEER }
      end
      context 'when ssl mode is anything else' do
        let(:verify_mode) { instance.handle_verify_mode('foo') }

        it { expect { verify_mode }.to raise_error Puppet::ResourceError, %r{"foo" is not a valid mode} }
      end
    end

    describe '#verify_callback' do
      let(:cert_store) { OpenSSL::X509::StoreContext.new(OpenSSL::X509::Store.new) }
      let(:certificate_1) { OpenSSL::X509::Certificate.new }
      let(:certificate_current) { OpenSSL::X509::Certificate.new }
      let(:chains) do
        [certificate_1]
      end

      context 'when preverify is false and no fingerprint' do
        let(:callback) { instance.verify_callback(false, anything) }

        it { expect(callback).to be_falsy }
      end
      context 'when preverify is false and has fingerprint' do
        let(:callback) { instance.verify_callback(false, cert_store) }

        it do
          allow(cert_store).to receive(:chain).and_return(chains)
          allow(cert_store).to receive(:current_cert).and_return(certificate_current)
          allow(certificate_1).to receive(:to_der).and_return('abc')
          allow(certificate_current).to receive(:to_der).and_return('abc')
          instance.instance_variable_set(:@fingerprint, 'X3:2B:AZ')
          allow(OpenSSL::Digest::SHA256).to receive(:hexdigest).with('abc').and_return('x32baz')
          expect(callback).to be_truthy
        end
      end
      context 'when preverify is true and has no fingerprint' do
        let(:callback) { instance.verify_callback(true, cert_store) }

        it do
          allow(cert_store).to receive(:chain).and_return(chains)
          allow(cert_store).to receive(:current_cert).and_return(certificate_current)
          allow(certificate_1).to receive(:to_der).and_return('abc')
          allow(certificate_current).to receive(:to_der).and_return('abc')
          expect(callback).to be_truthy
        end
      end
    end

    describe '#same_cert_fingerprint?' do
      let(:end_cert) { OpenSSL::X509::Certificate.new }
      let(:same_cert) { instance.same_cert_fingerprint?(end_cert) }

      context 'when fingerprints match' do
        it do
          instance.instance_variable_set(:@fingerprint, 'X3:2B:AZ')
          allow(end_cert).to receive(:to_der).and_return('abc')
          allow(OpenSSL::Digest::SHA256).to receive(:hexdigest).with('abc').and_return('x32baz')
          expect(same_cert).to be_truthy
        end
      end
      context 'when fingerprints do not match' do
        it do
          instance.instance_variable_set(:@fingerprint, 'A3:2Z:8Z')
          allow(end_cert).to receive(:to_der).and_return('abc')
          allow(OpenSSL::Digest::SHA256).to receive(:hexdigest).with('abc').and_return('x32baz')
          expect(same_cert).to be_falsy
        end
      end
    end

    describe '#http' do
      let(:cert_store) { OpenSSL::X509::StoreContext.new(OpenSSL::X509::Store.new) }
      let(:certificate_1) { OpenSSL::X509::Certificate.new }
      let(:certificate_current) { OpenSSL::X509::Certificate.new }
      let(:chains) do
        [certificate_1]
      end
      let(:start_block) do
        {
          use_ssl: true,
          verify_mode: OpenSSL::SSL::VERIFY_PEER,
          ca_file: nil,
          ssl_version: nil,
          ciphers: nil,
          verify_callback: ->(composed_lambda) {
            expect(composed_lambda.call(true, cert_store)).to eq true
          },
        }
      end

      before(:each) do
        allow(cert_store).to receive(:chain).and_return(chains)
        allow(cert_store).to receive(:current_cert).and_return(certificate_current)
        allow(certificate_1).to receive(:to_der).and_return('abc')
        allow(certificate_current).to receive(:to_der).and_return('abc')
      end
      context 'when http is called it will start the connection' do
        it do
          expect(Net::HTTP).to receive(:start).with('www.example.com', 443, start_block)
          instance.http
        end
      end
      context 'when http is called and throws a verify error' do
        it do
          instance.instance_variable_set(:@ssl_verify, 'foo')
          expect { instance.http }.to raise_error Puppet::ResourceError, %r{"foo" is not a valid mode}
        end
      end
      context 'when http is called and throws a SSL error' do
        it do
          expect(Net::HTTP).to receive(:start).with('www.example.com', 443, start_block).and_raise OpenSSL::SSL::SSLError
          expect { instance.http }.to raise_error OpenSSL::SSL::SSLError
        end
      end
    end

    describe '#job_request(type, **options)' do
      let(:credentials) { super().merge(apikey: apikey) }

      before(:each) do
        # disable sleeping, due to how this is called (objects inheriting from Kernel) this requires a lot of wrangling
        # See https://stackoverflow.com/a/27749263/4918
        allow_any_instance_of(Object).to receive(:sleep) # rubocop:disable RSpec/AnyInstance
      end

      # this part is a bit wonky, because "commit" is currently the only job we're using/testing
      # other async jobs might never return this, or return something different
      context 'when the job is not required' do
        before(:each) do
          stub_request(:get, 'https://www.example.com/api/?cmd=<commit></commit>&key=APIKEY&type=commit')
            .to_return(status: 200, body: '<response status="success" code="19"><msg>There are no changes to commit.</msg></response>')
        end

        it 'returns immediately' do
          instance.job_request('commit', cmd: '<commit></commit>')
        end
      end

      context 'straight to success' do
        it do
          stub_request(:get, 'https://www.example.com/api/?cmd=<commit></commit>&key=APIKEY&type=commit')
            .to_return(status: 200, body: '<response status="success" code="19"><result><msg><line>Commit job enqueued with jobid 2</line></msg><job>2</job></result></response>')
          # rubocop:disable Metrics/LineLength
          stub_request(:get, 'https://www.example.com/api/?cmd=<show><jobs><id>2</id></jobs></show>&key=APIKEY&type=op')
            .to_return(status: 200, body: '<response status="success"><result><job><tenq>2018/06/12 04:36:45</tenq><tdeq>04:36:45</tdeq><id>2</id><user>admin</user><type>Commit</type><status>FIN</status><queued>NO</queued><stoppable>no</stoppable><result>OK</result><tfin>04:36:57</tfin><description></description><positionInQ>0</positionInQ><progress>100</progress><details><line>Configuration committed successfully</line></details><warnings></warnings></job></result></response>')
          # rubocop:enable Metrics/LineLength

          instance.job_request('commit', cmd: '<commit></commit>')
        end
      end
      context 'waiting for it' do
        it do
          stub_request(:get, 'https://www.example.com/api/?cmd=<commit></commit>&key=APIKEY&type=commit')
            .to_return(status: 200, body: '<response status="success" code="19"><result><msg><line>Commit job enqueued with jobid 2</line></msg><job>2</job></result></response>')
          # rubocop:disable Metrics/LineLength
          stub_request(:get, 'https://www.example.com/api/?cmd=<show><jobs><id>2</id></jobs></show>&key=APIKEY&type=op')
            .to_return([
                         { status: 200, body: '<response status="success"><result><job><tenq>2018/06/12 04:36:45</tenq><tdeq>04:36:45</tdeq><id>2</id><user>admin</user><type>Commit</type><status>ACT</status><queued>NO</queued><stoppable>yes</stoppable><result>PEND</result><tfin>Still Active</tfin><description></description><positionInQ>0</positionInQ><progress>0</progress><warnings></warnings><details></details></job></result></response>' },
                         { status: 200, body: '<response status="success"><result><job><tenq>2018/06/12 04:36:45</tenq><tdeq>04:36:45</tdeq><id>2</id><user>admin</user><type>Commit</type><status>ACT</status><queued>NO</queued><stoppable>yes</stoppable><result>PEND</result><tfin>Still Active</tfin><description></description><positionInQ>0</positionInQ><progress>0</progress><warnings></warnings><details></details></job></result></response>' },
                         { status: 200, body: '<response status="success"><result><job><tenq>2018/06/12 04:36:45</tenq><tdeq>04:36:45</tdeq><id>2</id><user>admin</user><type>Commit</type><status>ACT</status><queued>NO</queued><stoppable>yes</stoppable><result>PEND</result><tfin>Still Active</tfin><description></description><positionInQ>0</positionInQ><progress>75</progress><warnings></warnings><details></details></job></result></response>' },
                         { status: 200, body: '<response status="success"><result><job><tenq>2018/06/12 04:36:45</tenq><tdeq>04:36:45</tdeq><id>2</id><user>admin</user><type>Commit</type><status>ACT</status><queued>NO</queued><stoppable>no</stoppable><result>PEND</result><tfin>Still Active</tfin><description></description><positionInQ>0</positionInQ><progress>99</progress><warnings></warnings><details></details></job></result></response>' },
                         { status: 200, body: '<response status="success"><result><job><tenq>2018/06/12 04:36:45</tenq><tdeq>04:36:45</tdeq><id>2</id><user>admin</user><type>Commit</type><status>FIN</status><queued>NO</queued><stoppable>no</stoppable><result>OK</result><tfin>04:36:57</tfin><description></description><positionInQ>0</positionInQ><progress>100</progress><details><line>Configuration committed successfully</line></details><warnings></warnings></job></result></response>' },
                       ])
          # rubocop:enable Metrics/LineLength

          instance.job_request('commit', cmd: '<commit></commit>')
        end
      end

      context 'when the job fails' do
        it do
          stub_request(:get, 'https://www.example.com/api/?cmd=<validate><full></full></validate>&key=APIKEY&type=op')
            .to_return(status: 200, body: '<response status="success" code="19"><result><msg><line>Validate job enqueued with jobid 2</line></msg><job>2</job></result></response>')
          # rubocop:disable Metrics/LineLength
          stub_request(:get, 'https://www.example.com/api/?cmd=<show><jobs><id>2</id></jobs></show>&key=APIKEY&type=op')
            .to_return([
                         { status: 200, body: '<response status="success"><result><job><tenq>2018/06/12 09:26:45</tenq><tdeq>09:26:45</tdeq><id>8</id><user>admin</user><type>Validate</type><status>ACT</status><queued>NO</queued><stoppable>yes</stoppable><result>PEND</result><tfin>Still Active</tfin><description></description><positionInQ>0</positionInQ><progress>0</progress><warnings></warnings><details></details></job></result></response>' },
                         { status: 200, body: '<response status="success"><result><job><tenq>2018/06/12 09:26:45</tenq><tdeq>09:26:45</tdeq><id>8</id><user>admin</user><type>Validate</type><status>ACT</status><queued>NO</queued><stoppable>yes</stoppable><result>PEND</result><tfin>Still Active</tfin><description></description><positionInQ>0</positionInQ><progress>0</progress><warnings></warnings><details></details></job></result></response>' },
                         { status: 200, body: '<response status="success"><result><job><tenq>2018/06/12 09:26:45</tenq><tdeq>09:26:45</tdeq><id>8</id><user>admin</user><type>Validate</type><status>FIN</status><queued>NO</queued><stoppable>no</stoppable><result>FAIL</result><tfin>09:26:47</tfin><description></description><positionInQ>0</positionInQ><progress>100</progress><details><line>Validation Error:</line><line><![CDATA[ address -> address-3 Node ip-netmask(line 30226) and ip-range(line 30227) are mutually exclusive]]></line><line><![CDATA[ address -> address-3 Node ip-netmask(line 30226) and fqdn(line 30228) are mutually exclusive]]></line><line><![CDATA[ address is invalid]]></line><line><![CDATA[ vsys is invalid]]></line><line><![CDATA[ devices is invalid]]></line></details><warnings></warnings></job></result></response>' },
                       ])
          # rubocop:enable Metrics/LineLength

          expect { instance.job_request('op', cmd: '<validate><full></full></validate>') }.to raise_error Puppet::ResourceError, %r{Validation Error:}
        end
      end
    end
  end
end
