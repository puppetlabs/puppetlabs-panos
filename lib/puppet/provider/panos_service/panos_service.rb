require_relative '../panos_provider'
require 'rexml/document'
require 'builder'

# Implementation for the panos_service_type type using the Resource API.
class Puppet::Provider::PanosService::PanosService < Puppet::Provider::PanosProvider
  def xml_from_should(name, should)
    builder = Builder::XmlMarkup.new
    builder.entry('name' => name) do
      builder.protocol do
        builder.__send__(should[:protocol]) do
          builder.port(should[:port])
          builder.__send__('source-port', should[:src_port]) unless should[:src_port] == '' || should[:src_port].nil?
        end
      end
      builder.description(should[:description]) if should[:description]
      build_tags(builder, should)
    end
  end
end
