require 'spec_helper'
require 'support/shared_examples'

module Puppet::Provider::PanosApplicationGroup; end
require 'puppet/provider/panos_application_group/panos_application_group'

RSpec.describe Puppet::Provider::PanosApplicationGroup::PanosApplicationGroup do
  subject(:provider) { described_class.new }

  describe 'validate_should(should)' do
    context 'when type is correct' do
      let(:should_hash) do
        {
          name: 'demo_group',
          ensure: 'present',
          members: ['ssl', 'google-base']
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when does not contain members' do
      let(:should_hash) do
        {
          name: 'demo_group',
          ensure: 'present'
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{Application group should contain `members`} }
    end
  end

  test_data = [
    {
      desc: 'an example of an application_group',
      attrs: {
        name:           'app_group',
        ensure:         'present',
        members:           ['foo', 'bar']
      },
      xml:  '<entry name="app_group">
              <members>
                <member>foo</member>
                <member>bar</member>
              </members>
            </entry>',
    },
  ]

  include_examples 'xml_from_should(name, should)', test_data, described_class.new
end
