# frozen_string_literal: true

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
  end

  describe '#canonicalize(_context, resources)' do
    let(:resource) do
      [
        {
          foo: 'bar',
          color: color,
        },
      ]
    end
    let(:canonicalised_resource) do
      [
        {
          foo: 'bar',
          color: 'red',
        },
      ]
    end

    context 'when resource contains a color name' do
      let(:color) { 'red' }

      it { expect(panos_tag.canonicalize(nil, resource)).to eq canonicalised_resource }
    end
    context 'when resource contains a color name in upper case' do
      let(:color) { 'RED' }

      it { expect(panos_tag.canonicalize(nil, resource)).to eq canonicalised_resource }
    end
    context 'when resource contains a color tag' do
      let(:color) { 'color1' }

      it { expect(panos_tag.canonicalize(nil, resource)).to eq canonicalised_resource }
    end
    context 'when resource does not contain a color' do
      let(:resource) do
        [
          {
            foo: 'bar',
          },
        ]
      end

      it { expect(panos_tag.canonicalize(nil, resource)).to eq resource }
    end
  end

  describe 'validate_should(should)' do
    context 'when an invalid color is provided' do
      let(:entry) { { color: 'cotton' } }

      it { expect { panos_tag.validate_should(entry) }.to raise_error Puppet::ResourceError, %r{Please use one of the existing Palo Alto colors.} }
    end
    context 'when a valid color name is provided' do
      let(:entry) { { color: 'red' } }

      it { expect { panos_tag.validate_should(entry) }.not_to raise_error }
    end
    context 'when a valid color index is provided' do
      let(:entry) { { color: 'color1' } }

      it { expect { panos_tag.validate_should(entry) }.not_to raise_error }
    end
    context 'when no color is provided' do
      let(:entry) { {} }

      it { expect { panos_tag.validate_should(entry) }.not_to raise_error }
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
