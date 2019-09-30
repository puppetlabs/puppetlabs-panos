require_relative '../panos_provider'

# Implementation for the panos_custom_url_category type using the Resource API.
class Puppet::Provider::PanosCustomUrlCategory::PanosCustomUrlCategory < Puppet::Provider::PanosProvider
  def validate_should(should)
    if should[:list].nil?
      raise Puppet::ResourceError, 'URL Category should contain `list`'
    end
  end

  def xml_from_should(name, should)
    builder = Builder::XmlMarkup.new
    builder.entry('name' => name) do
      builder.description(should[:description]) if should[:description]

      builder.list do
        should[:list].each do |member|
          builder.member(member)
        end
      end

      build_tags(builder, should)
    end
  end
end
