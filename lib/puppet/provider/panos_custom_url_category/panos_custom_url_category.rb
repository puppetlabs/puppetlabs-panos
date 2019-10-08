require_relative '../panos_provider'

# Implementation for the panos_custom_url_category type using the Resource API.
class Puppet::Provider::PanosCustomUrlCategory::PanosCustomUrlCategory < Puppet::Provider::PanosProvider
  def validate_should(should)
    raise Puppet::ResourceError, 'URL Category should contain `list`' unless should[:list]

    return unless should[:category_type].nil?

    raise Puppet::ResourceError, 'Type should be `URL List` or `Category Match`' unless should[:category_type] == 'URL List' || should[:category_type] == 'Category Match'
  end

  def xml_from_should(name, should)
    builder = Builder::XmlMarkup.new
    builder.entry('name' => name) do
      builder.description(should[:description]) if should[:description]

      builder.type(should[:category_type]) if should[:category_type]

      builder.list do
        should[:list].each do |member|
          builder.member(member)
        end
      end

      build_tags(builder, should)
    end
  end
end
