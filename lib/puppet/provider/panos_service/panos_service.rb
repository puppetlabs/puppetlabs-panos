require 'puppet/provider/panos_provider'
require 'rexml/document'
require 'builder'

# Implementation for the panos_service_type type using the Resource API.
class Puppet::Provider::PanosService::PanosService < Puppet::Provider::PanosProvider
  def validate_should(should)
    if should[:src_port].nil? && should[:dest_port].nil? # rubocop:disable Style/GuardClause # line too long
      raise Puppet::ResourceError, '`src_port` or `dest_port` must be provided'
    end
  end

  def xml_from_should(name, should)
    builder = Builder::XmlMarkup.new
    builder.entry('name' => name) do
      builder.protocol do
        builder.__send__(should[:protocol]) do
          builder.port(should[:dest_port]) unless should[:dest_port] == '' || should[:dest_port].nil?
          builder.__send__('source-port', should[:src_port]) unless should[:src_port] == '' || should[:src_port].nil?
        end
      end
      builder.description(should[:description]) if should[:description]
      build_tags(builder, should)
    end
  end
end
