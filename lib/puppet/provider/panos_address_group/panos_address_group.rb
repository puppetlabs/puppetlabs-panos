require_relative '../panos_provider'

# Implementation for the panos_address_group type using the Resource API.
class Puppet::Provider::PanosAddressGroup::PanosAddressGroup < Puppet::Provider::PanosProvider
  def validate_should(should)
    if should[:type] == 'static' && !should.key?(:static_members)
      raise Puppet::ResourceError, 'Static Address group must provide `static_members`'
    end
    if should[:type] == 'dynamic' && !should.key?(:dynamic_filter) # rubocop:disable Style/GuardClause # line too long
      raise Puppet::ResourceError, 'Dynamic Address group must provide `dynamic_filter`'
    end
  end

  def xml_from_should(name, should)
    builder = Builder::XmlMarkup.new
    builder.entry('name' => name) do
      builder.description(should[:description]) if should[:description]
      if should[:type] == 'static'
        builder.static do
          should[:static_members].each do |member|
            builder.member(member)
          end
        end
      elsif should[:type] == 'dynamic'
        builder.dynamic do
          builder.filter(should[:dynamic_filter])
        end
      end
      build_tags(builder, should)
    end
  end
end
