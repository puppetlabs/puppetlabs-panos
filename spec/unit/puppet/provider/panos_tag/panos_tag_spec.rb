require 'spec_helper'
require 'support/shared_examples'

module Puppet::Provider::PanosTag; end
require 'puppet/provider/panos_tag/panos_tag'

RSpec.describe Puppet::Provider::PanosTag::PanosTag do
  subject(:panos_tag) { described_class.new }

  describe 'munge(entry)' do
    context 'when color provided is red' do
      let(:entry) { { color: 'color1' } }
      let(:result) { { color: 'red' } }

      it { expect(panos_tag.munge(entry)).to eq(result) }
    end
    context 'when an invalid color is provided' do
      let(:entry) { { color: '12' } }

      it { expect { panos_tag.munge(entry) }.to raise_error Puppet::ResourceError, %r{Please use one of the existing Palo Alto colors.} }
    end
  end

  test_data = [
    {
      desc: 'an example with a name, color and comments',
      attrs: {
        name:         'name, color and comments',
        ensure:       'present',
        comments:     'abc',
        color:        'blue',
      },
      xml: '<entry name="name, color and comments">
            <color>color3</color>
            <comments>abc</comments>
          </entry>',
    },
    {
      desc: 'an example with a name and comments',
      attrs: {
        name:         'name and comments',
        ensure:       'present',
        comments:     'abc',
      },
      xml: '<entry name="name and comments">
            <comments>abc</comments>
            </entry>',
    },
    {
      desc: 'an example with a name and color',
      attrs: {
        name:         'name and color',
        ensure:       'present',
        color:        'blue',
      },
      xml: '<entry name="name and color">
            <color>color3</color>
            </entry>',
    },
    {
      desc: 'an example with a name',
      attrs: {
        name:         'name',
        ensure:       'present',
      },
      xml: '<entry name="name">
            </entry>',
    },
    {
      desc: 'an example without a color',
      attrs: {
        name:         'name',
        ensure:       'present',
        comments:     'test comments, no color',
      },
      xml: '<entry name="name">
            <comments>test comments, no color</comments>
            </entry>',
    },

  ]

  include_examples 'xml_from_should(name, should)', test_data, described_class.new
end
