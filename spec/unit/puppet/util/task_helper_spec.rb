# frozen_string_literal: true

require 'json'
require 'puppet/util/task_helper'
begin
  require 'puppet/resource_api/transport'
rescue LoadError
  require 'puppet_x/puppetlabs/panos/transport_shim'
end

RSpec.describe Puppet::Util::TaskHelper do
  let(:helper) { described_class.new('panos') }
  let(:params) { {} }

  before(:each) do
    allow(STDIN).to receive(:read).and_return(JSON.generate(params))
  end

  it 'does not throw' do
    expect { helper }.not_to raise_error
  end

  context 'when `_installdir` is present' do
    let(:params) do
      {
        '_installdir' => '.',
      }
    end

    it 'does not throw' do
      expect { helper }.not_to raise_error
    end
  end

  describe '#transport' do
    let(:creds) do
      {
        host: '1.2.3.4',
        user: 'admin',
        password: 'admin',
      }
    end
    let(:params) do
      {
        '_target' => creds,
      }
    end

    it 'returns a transport object' do
      expect(Puppet::ResourceApi::Transport).to receive(:connect).with('panos', creds)
      helper.transport
    end
  end

  describe '#params' do
    context 'when params are provided through STDIN' do
      let(:params) do
        {
          'foo' => 'wibble',
        }
      end

      it { expect(helper.params).to eq('foo' => 'wibble') }
    end
    context 'when params are provided through ENV' do
      let(:env) { '{"wibble": "foo"}' }

      it {
        allow(ENV).to receive(:[]).with('PARAMS').and_return(env)
        expect(helper.params).to eq('wibble' => 'foo')
      }
    end
  end

  describe '#target' do
    let(:creds) do
      {
        host: '1.2.3.4',
        user: 'admin',
        password: 'admin',
      }
    end
    let(:params) do
      {
        '_target' => creds,
      }
    end

    it 'returns  the creds with string keys' do
      expect(helper.target).to eq('host' => '1.2.3.4',
                                  'password' => 'admin',
                                  'user' => 'admin')
    end
  end

  describe '#credentials' do
    let(:creds) do
      {
        host: '1.2.3.4',
        user: 'admin',
        password: 'admin',
      }
    end
    let(:params) do
      {
        '_target' => creds,
      }
    end

    it 'returns the creds with symbolised keys' do
      expect(helper.credentials).to eq(host: '1.2.3.4',
                                       password: 'admin',
                                       user: 'admin')
    end
  end
end
