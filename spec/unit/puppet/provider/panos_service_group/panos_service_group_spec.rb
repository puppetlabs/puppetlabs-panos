require 'spec_helper'
require 'support/shared_examples'

# TODO: needs some cleanup/helper to avoid this misery
module Puppet::Provider::PanosServiceGroup; end
require 'puppet/provider/panos_service_group/panos_service_group'

RSpec.describe Puppet::Provider::PanosServiceGroup::PanosServiceGroup do
  test_data = [
    {
      desc: 'an example with multiple services',
      attrs: {
        name:     'test group',
        ensure:   'present',
        services: ['wibble', 'wobble'],
        tags:     ['foo', 'bar'],
      },
      xml: '<entry name="test group">
              <members>
                <member>wibble</member>
                <member>wobble</member>
              </members>
              <tag>
                <member>foo</member>
                <member>bar</member>
              </tag>
            </entry>',
    },
    {
      desc: 'an example with a single service',
      attrs: {
        name:     'test group 2',
        ensure:   'present',
        services: ['foo'],
        tags:     [],
      },
      xml: '<entry name="test group 2">
              <members>
                <member>foo</member>
              </members>
              <tag></tag>
            </entry>',
    },
  ]

  include_examples 'xml_from_should(name, should)', test_data, described_class.new
end
