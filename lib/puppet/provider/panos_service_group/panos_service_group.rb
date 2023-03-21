require_relative '../panos_vsys_base'

# Implementation for the panos_service_group type using the Resource API.
class Puppet::Provider::PanosServiceGroup::PanosServiceGroup < Puppet::Provider::PanosVsysBase
  def xml_from_should(name, should)
    builder = Builder::XmlMarkup.new
    builder.entry('name' => name) do
      builder.members do
        should[:services].each do |service|
          builder.member(service)
        end
      end
      build_tags(builder, should)
    end
  end
end
