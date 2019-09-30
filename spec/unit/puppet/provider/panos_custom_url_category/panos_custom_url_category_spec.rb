require 'spec_helper'
require 'support/shared_examples'

module Puppet::Provider::PanosCustomUrlCategory; end
require 'puppet/provider/panos_custom_url_category/panos_custom_url_category'

RSpec.describe Puppet::Provider::PanosCustomUrlCategory::PanosCustomUrlCategory do
  subject(:provider) { described_class.new }

  describe 'validate_should(should)' do
    context 'when type is correct' do
      let(:should_hash) do
        {
          name: 'demo_group',
          ensure: 'present',
          list: ['ssl', 'google-base'],
          description: 'description',
        }
      end

      it { expect { provider.validate_should(should_hash) }.not_to raise_error }
    end
    context 'when does not contain lists' do
      let(:should_hash) do
        {
          name: 'demo_group',
          ensure: 'present',
        }
      end

      it { expect { provider.validate_should(should_hash) }.to raise_error Puppet::ResourceError, %r{URL Category should contain `list`} }
    end
  end

  test_data = [
    {
      desc: 'an example of an custom_url_category',
      attrs: {
        name:           'url_category',
        ensure:         'present',
        list:           ['foo', 'bar'],
        description: 'description',
      },
      xml:  '<entry name="url_category">
              <description>description</description>
              <list>
                <member>foo</member>
                <member>bar</member>
              </list>
            </entry>',
    },
  ]

  include_examples 'xml_from_should(name, should)', test_data, described_class.new
end
