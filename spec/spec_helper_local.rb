require 'rexml/document'
begin
  require 'puppet/resource_api/transport'
rescue LoadError
  require 'puppet_x/puppetlabs/panos/transport_shim'
end
