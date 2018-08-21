require 'spec_helper_acceptance'
require 'json'

describe 'Config task' do
  before(:each) do
    params = {
      'credentials_file' => "file://#{Dir.getwd}/spec/fixtures/acceptance-credentials.conf",
      'config_file' => 'spec/fixtures/config-acceptance.txt',
      'apply' => apply,
    }

    ENV['PARAMS'] = JSON.generate(params)
  end

  let(:result) do
    puts "Executing config.rb task with `#{ENV['PARAMS']}`" if debug_output?
    Open3.capture2e('bundle exec ruby -Ilib tasks/config.rb')
  end
  let(:stdout_str) { result[0] }
  let(:status) { result[1] }

  context 'when apply is false' do
    let(:apply) { false }

    it 'will upload the configuration file but not load it' do
      expect(stdout_str).not_to match %r{Loading Config}
      expect(stdout_str).to match %r{Importing configuration}
      puts stdout_str if debug_output?
      expect(status.exitstatus).to eq 0
    end
  end
  context 'when apply is true' do
    let(:apply) { true }

    it 'will upload the configuration file and load it' do
      expect(stdout_str).to match %r{Loading Config}
      expect(stdout_str).to match %r{Importing configuration}
      puts stdout_str if debug_output?
      expect(status.exitstatus).to eq 0
    end
  end
end
