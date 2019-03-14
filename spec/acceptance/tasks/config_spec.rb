require 'spec_helper_acceptance'
require 'json'

describe 'Config task' do
  before(:each) do
    params = {
      '_target' => {
        'host' => RSpec.configuration.host,
        'user' => RSpec.configuration.user,
        'password' => RSpec.configuration.password,
      },
      'config_file' => config,
      'apply' => apply,
    }

    ENV['PARAMS'] = JSON.generate(params)
  end

  let(:result) do
    puts "Executing set_config.rb task with `#{ENV['PARAMS']}`" if debug_output?
    Open3.capture2e('bundle exec ruby -Ilib tasks/set_config.rb')
  end
  let(:stdout_str) { result[0] }
  let(:status) { result[1] }

  after(:all) do
    params = {
      '_target' => {
        'host' => RSpec.configuration.host,
        'user' => RSpec.configuration.user,
        'password' => RSpec.configuration.password,
      },
      'config_file' => 'spec/fixtures/config-reset.xml',
      'apply' => true,
    }
    ENV['PARAMS'] = JSON.generate(params)
    Open3.capture2e('bundle exec ruby -Ilib tasks/set_config.rb')
    Open3.capture2e('bundle exec ruby -Ilib tasks/commit.rb')
  end

  context 'when apply is false' do
    let(:config) { 'spec/fixtures/config-acceptance.xml' }
    let(:apply) { false }

    it 'will upload the configuration file but not load it' do
      expect(stdout_str).to match %r{\{\}}
      expect(stdout_str).not_to match %r{_error}
      puts stdout_str if debug_output?
      expect(status.exitstatus).to eq 0
    end
  end
  context 'when apply is true' do
    let(:config) { 'spec/fixtures/config-acceptance.xml' }
    let(:apply) { true }

    it 'will upload the configuration file and load it' do
      expect(stdout_str).to match %r{\{\}}
      expect(stdout_str).not_to match %r{_error}
      puts stdout_str if debug_output?
      expect(status.exitstatus).to eq 0
    end

    context 'when running an idempotency check' do
      let(:common_args) do
        '--detailed-exitcodes --verbose --debug --trace --strict=error --libdir lib --modulepath spec/fixtures/modules --deviceconfig spec/fixtures/acceptance-device.conf --target sut'
      end
      let(:args) { '--apply spec/fixtures/create.pp' }

      it 'applies a catalog without changes' do
        puts "Executing `puppet device #{common_args} #{args}`" if debug_output?
        Open3.capture2e("puppet device #{common_args} #{args}")
        expect(stdout_str).not_to match %r{Error:}
        expect(stdout_str).not_to match %r{Notice: panos_commit\[commit\]: Updating: Finished in \d+.\d+ seconds}
        puts stdout_str if debug_output?
        # See https://tickets.puppetlabs.com/browse/PUP-9067 "`puppet device` should respect --detailed-exitcodes"
        # expect(status.exitstatus).to eq 0
      end
    end
  end
  context 'when reset' do
    let(:config) { 'spec/fixtures/config-reset.xml' }
    let(:apply) { true }

    it 'will upload the configuration file and load it' do
      expect(stdout_str).to match %r{\{\}}
      expect(stdout_str).not_to match %r{_error}
      puts stdout_str if debug_output?
      expect(status.exitstatus).to eq 0
    end
  end
end
