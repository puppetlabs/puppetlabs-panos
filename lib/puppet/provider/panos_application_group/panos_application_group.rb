require_relative '../panos_provider'

# Implementation for the panos_application_group type using the Resource API.
class Puppet::Provider::PanosApplicationGroup::PanosApplicationGroup < Puppet::Provider::PanosProvider
  def validate_should(should)
    if should[:members].nil?
      raise Puppet::ResourceError, 'Application group should contain `members`'
    end
  end

  def xml_from_should(name, should)
    builder = Builder::XmlMarkup.new
    builder.entry('name' => name) do
      builder.members do
        should[:members].each do |member|
          builder.member(member)
        end
      end

      build_tags(builder, should)
    end
  end
end
