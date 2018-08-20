require 'spec_helper_acceptance'

describe 'basic palo alto config' do
  let(:common_args) { '--detailed-exitcodes --verbose --debug --trace --strict=error --libdir lib --modulepath spec/fixtures/modules --deviceconfig spec/fixtures/acceptance-device.conf --target sut' }

  let(:result) do
    puts "Executing `puppet device #{common_args} #{args}`" if debug_output?
    Open3.capture2e("puppet device #{common_args} #{args}")
  end
  let(:stdout_str) { result[0] }
  let(:status) { result[1] }

  let(:args) { '--apply spec/fixtures/basics.pp' }

  context 'when running the first time' do
    it 'applies a catalog with changes' do
      expect(stdout_str).not_to match %r{Error:}
      expect(stdout_str).to match %r{Notice: panos_commit\[commit\]: Updating: Finished in \d+.\d+ seconds}
      puts stdout_str if debug_output?
      # See https://tickets.puppetlabs.com/browse/PUP-9067 "`puppet device` should respect --detailed-exitcodes"
      # expect(status.exitstatus).to eq 2
    end

    context 'when running the second time' do
      it 'applies a catalog without changes' do
        expect(stdout_str).not_to match %r{Error:}
        expect(stdout_str).not_to match %r{Notice: panos_commit\[commit\]: Updating: Finished in \d+.\d+ seconds}
        puts stdout_str if debug_output?
        # See https://tickets.puppetlabs.com/browse/PUP-9067 "`puppet device` should respect --detailed-exitcodes"
        # expect(status.exitstatus).to eq 0
      end
    end
  end
end
