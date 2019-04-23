require 'puppet'
begin
  require 'puppet/resource_api/transport/wrapper'
rescue LoadError
  require 'puppet_x/puppetlabs/panos/transport_shim'
end
# force registering the transport
require 'puppet/transport/schema/panos'

module Puppet::Util::NetworkDevice::Panos
  # connect to a panos transport using backwards compatible configuration
  class Device < Puppet::ResourceApi::Transport::Wrapper
    def initialize(url_or_config, _options = {})
      super('panos', url_or_config)
    end
  end
end
