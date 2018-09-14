require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'panos_arbitrary_commands',
  docs: <<-EOS,
      This type provides Puppet with the capabilities to execute arbitrary configuration commands on Palo Alto devices.
    EOS
  features: ['simple_get_filter', 'remote_resource', 'canonicalize'],
  attributes: {
    ensure: {
      type:    'Enum[present, absent]',
      desc:    'Whether this resource should be present or absent on the target system.',
      default: 'present',
    },
    xpath: {
      type:      'String',
      desc:      'The PANOS API XPath on which to set the `xml`.',
      behaviour: :namevar,
    },
    xml:  {
      type: 'String',
      desc: 'The XML to be set on the device. If working with large XML structures it is recommended to use the file() function e.g.: file(path/to/file.xml).',
    },
  },
  autobefore: {
    panos_commit: 'commit',
  },
)
