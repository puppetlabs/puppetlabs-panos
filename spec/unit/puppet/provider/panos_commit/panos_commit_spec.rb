require 'spec_helper'

ensure_module_defined('Puppet::Provider::PanosCommit')
require 'puppet/provider/panos_commit/panos_commit'

RSpec.describe Puppet::Provider::PanosCommit::PanosCommit do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:transport) { instance_double('Puppet::ResourceApi::Transport::Panos', 'transport') }

  before(:each) do
    allow(context).to receive(:transport).with(no_args).and_return(transport)
    allow(transport).to receive(:outstanding_changes?).and_return(outstanding_changes)
  end

  describe '#get' do
    context 'when there are outstanding changes' do
      let(:outstanding_changes) { true }

      it do
        expect(provider.get(context)).to eq [
          {
            name: 'commit',
            commit: false,
          },
        ]
      end
    end
    context 'when there are no outstanding changes' do
      let(:outstanding_changes) { false }

      it do
        expect(provider.get(context)).to eq [
          {
            name: 'commit',
            commit: true,
          },
        ]
      end
    end
  end

  describe 'set(context, changes)' do
    context 'when there are outstanding changes' do
      let(:outstanding_changes) { true }

      context 'when the user requested a commit' do
        it 'commits them' do
          allow(context).to receive(:updating).with('commit').and_yield
          expect(transport).to receive(:commit)
          provider.set(context, 'commit' => { should: { commit: true } })
        end
      end

      context 'when the user did not request a commit' do
        it 'ignores them' do
          expect(context).to receive(:info).with('changes detected, but skipping commit as requested')
          expect(context).not_to receive(:updating).with('commit').and_yield
          expect(transport).not_to receive(:commit)
          provider.set(context, 'commit' => { should: { commit: false } })
        end
      end
    end

    context 'when there are no outstanding changes' do
      let(:outstanding_changes) { false }

      it 'emits a debug message' do
        expect(context).to receive(:debug).with('no changes detected')
        provider.set(context, 'commit' => { should: { commit: false } })
      end
    end
  end
end
