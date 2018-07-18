require 'spec_helper'
require 'puppet/util/network_device/panos/device'
require 'support/matchers/have_xml'

RSpec.describe Puppet::Util::NetworkDevice::Panos do
  describe Puppet::Util::NetworkDevice::Panos::Device do
    let(:device) { described_class.new('file:///') }
    let(:xml_doc) { REXML::Document.new(device_hash) }
    let(:device_hash) do
      '<response status="success">
        <result>
          <sw-version>7.1.0</sw-version>
          <multi-vsys>off</multi-vsys>
          <model>PA-VM</model>
        </result>
      </response>'
    end

    it 'parses facts correctly' do
      expect(device.parse_device_facts(xml_doc)).to eq('operatingsystem' => 'PA-VM', 'operatingsystemrelease' => '7.1.0', 'multi-vsys' => 'off')
    end

    describe '#facts' do
      it 'parses device facts' do
      end
    end
  end

  describe Puppet::Util::NetworkDevice::Panos::API do
    subject(:instance) { described_class.new(credentials) }

    let(:credentials) { { 'host' => 'www.example.com' } }

    def stub_keygen_request(**options)
      stub_request(:get, 'https://www.example.com/api/?password=password&type=keygen&user=user')
        .to_return(options)
    end

    def stub_api_request(**options)
      stub_request(:get, 'https://www.example.com/api/?type=THETYPE&key=APIKEY&option_a=ANOPTION')
        .to_return(options)
    end

    describe '#fetch_apikey(user, password)' do
      context 'with valid username and password' do
        it 'fetches the API key' do
          stub_keygen_request(status: 200, body: "<response status='success'><result><key>SOMEKEY</key></result></response>")

          expect(instance.fetch_apikey('user', 'password')).to eq 'SOMEKEY'

          expect(a_request(:get, 'https://www.example.com/api/?password=password&type=keygen&user=user')).to have_been_made.once
        end
      end

      context 'with invalid username and password' do
        it 'raises a helpful error' do
          stub_keygen_request(status: 403)

          expect { instance.fetch_apikey('user', 'password') }.to raise_error RuntimeError, %r{forbidden}i

          expect(a_request(:get, 'https://www.example.com/api/?password=password&type=keygen&user=user')).to have_been_made.once
        end
      end
    end

    describe '#apikey' do
      let(:credentials) { super().merge('user' => 'user', 'password' => 'password') }

      it 'makes only a single HTTP call' do
        stub_keygen_request(status: 200, body: "<response status = 'success'><result><key>SOMEKEY</key></result></response>")

        expect(instance.apikey).to eq 'SOMEKEY'
        expect(instance.apikey).to eq 'SOMEKEY'

        expect(a_request(:get, 'https://www.example.com/api/?password=password&type=keygen&user=user')).to have_been_made.once
      end
    end

    describe '#request(type, **options)' do
      let(:credentials) { super().merge('apikey' => 'APIKEY') }
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

    describe '#job_request(type, **options)' do
      let(:credentials) { super().merge('apikey' => 'APIKEY') }

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
