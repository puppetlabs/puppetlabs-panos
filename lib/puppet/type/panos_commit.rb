require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'panos_commit',
  docs: <<-EOS,
      @summary When evaluated, this resource commits all outstanding changes in the target device's configuration to the active configuration. It is automatically scheduled after all other PANOS resources.
    EOS
  features: ['remote_resource'],
  attributes: {
    name: {
      type:      'Enum["commit"]',
      desc:      'The name of the resource you want to manage. Can only be "commit".',
      behaviour: :namevar,
    },
    commit: {
      type:      'Boolean',
      desc:      'Whether a commit should happen',
      defaultto: false,
    },
  },
)
