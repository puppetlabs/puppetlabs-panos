require 'spec_helper_acceptance'

describe 'basic palo alto config' do
  let(:common_args) { '--detailed-exitcodes --verbose --debug --trace --strict=error --libdir lib --modulepath spec/fixtures/modules --deviceconfig spec/fixtures/acceptance-device.conf --target sut' }

  let(:result) do
    puts "Executing `puppet device #{common_args} #{args}`" if debug_output?
    Open3.capture2e("puppet device #{common_args} #{args}")
  end
  let(:stdout_str) { result[0] }
  let(:status) { result[1] }
  let(:success_regex) { %r{Notice: panos_commit\[commit\]: Updating: Finished in \d+.\d+ seconds} }

  let(:args) { '--apply spec/fixtures/create.pp' }

  let(:_target) do
    {
      'host' => RSpec.configuration.host,
      'user' => RSpec.configuration.user,
      'password' => RSpec.configuration.password,
      'ssl' => false,
    }
  end

  context 'when creating resources' do
    it 'applies a catalog with changes' do
      expect(stdout_str).not_to match %r{Error:}
      expect(stdout_str).to match success_regex
      puts stdout_str if debug_output?
      # See https://tickets.puppetlabs.com/browse/PUP-9067 "`puppet device` should respect --detailed-exitcodes"
      # expect(status.exitstatus).to eq 2
    end

    context 'when it gets the current running config' do
      it 'will get the current running config and store to file' do
        params = {
          '_target' => _target,
          'config_file' => 'spec/fixtures/config-acceptance.xml',
        }

        ENV['PARAMS'] = JSON.generate(params)
        puts "Executing store_config.rb task with `#{ENV['PARAMS']}`" if debug_output?
        result = Open3.capture2e('bundle exec ruby -Ilib tasks/store_config.rb')
        expect(result[0]).not_to match(%r{_error})
        expect(File).to be_exist(params['config_file'])
      end

      context 'when running an idempotency check' do
        it 'applies a catalog without changes' do
          expect(stdout_str).not_to match %r{Error:}
          expect(stdout_str).not_to match success_regex
          puts stdout_str if debug_output?
          # See https://tickets.puppetlabs.com/browse/PUP-9067 "`puppet device` should respect --detailed-exitcodes"
          # expect(status.exitstatus).to eq 0
        end

        context 'when applying a change' do
          let(:args) { '--apply spec/fixtures/update.pp' }

          it 'applies a catalog with changes' do
            expect(stdout_str).not_to match %r{Error:}
            expect(stdout_str).to match success_regex
            puts stdout_str if debug_output?
            # See https://tickets.puppetlabs.com/browse/PUP-9067 "`puppet device` should respect --detailed-exitcodes"
            # expect(status.exitstatus).to eq 2
          end

          context 'when removing resources' do
            let(:args) { '--apply spec/fixtures/delete.pp' }

            it 'applies a catalog with changes' do
              expect(stdout_str).not_to match %r{Error:}
              expect(stdout_str).to match success_regex
              puts stdout_str if debug_output?
              # See https://tickets.puppetlabs.com/browse/PUP-9067 "`puppet device` should respect --detailed-exitcodes"
              # expect(status.exitstatus).to eq 2
            end

            context 'when it gets the current running config' do
              it 'will get the current running config and store to file' do
                params = {
                  '_target' => _target,
                  'config_file' => 'spec/fixtures/config-reset.xml',
                }

                ENV['PARAMS'] = JSON.generate(params)
                puts "Executing store_config.rb task with `#{ENV['PARAMS']}`" if debug_output?
                Open3.capture2e('bundle exec ruby -Ilib tasks/store_config.rb')
                expect(File).to be_exist(params['config_file'])
              end
            end
          end
        end
      end
    end
  end
end
