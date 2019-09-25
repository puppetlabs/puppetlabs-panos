require_relative '../panos_provider'

# Implementation for the panos_decryption_policy_rule type using the Resource API.
class Puppet::Provider::PanosDecryptionPolicyRule::PanosDecryptionPolicyRule < Puppet::Provider::PanosProvider
  def munge(entry)
    none_attrs = [:profile_type, :qos_type]

    none_attrs.each do |attr|
      if entry.key?(attr) && entry[attr].nil?
        entry[attr] = 'none'
      end
    end


    bool_attrs = [ :negate_source, :negate_destination, :disable]
    bool_attrs.each do |attr|
      if entry.key? attr
        entry[attr] = string_to_bool(entry[attr])
      end
    end
    entry[:type] = 'ssl-forward-proxy' if entry[:rule_type].nil?
    #entry[:type] = '<' + entry[:type] + '/>'
    if entry.key?(:insert_after) && entry[:insert_after].nil?
      entry[:insert_after] = ''
    end
    entry
  end

  def validate_should(should)
    if should[:negate_source] == true && should[:source_zones].first == 'any'
      raise Puppet::ResourceError, '`negate_source` cannot be set when `source_zones` is [`any`].'
    end
    if should[:negate_destination] == true && should[:destination_zones].first == 'any' # rubocop:disable Style/GuardClause
      raise Puppet::ResourceError, '`negate_destination` cannot be set when `destination_zones` is [`any`].'
    end
  end

  def xml_from_should(name, should)
    builder = Builder::XmlMarkup.new
    builder.entry('name' => name) do
      builder.to do
        should[:destination_zones].each do |zone|
          builder.member(zone)
        end
      end
      builder.from do
        should[:source_zones].each do |zone|
          builder.member(zone)
        end
      end
      builder.source do
        should[:source_address].each do |address|
          builder.member(address)
        end
      end
      builder.destination do
        should[:destination_address].each do |address|
          builder.member(address)
        end
      end
      builder.__send__('source-user') do
        should[:source_users].each do |user|
          builder.member(user)
        end
      end
      builder.category do
        should[:categories].each do |category|
          builder.member(category)
        end
      end
      builder.service do
        should[:services].each do |service|
          builder.member(service)
        end
      end

      builder.action(should[:action])

      builder.type do
        builder.tag! should[:type], nil
      end

      builder.description(should[:description]) if should[:description]

      build_tags(builder, should)

      builder.__send__('negate-source', bool_to_string(should[:negate_source])) unless should[:negate_source].nil?

      builder.__send__('negate-destination', bool_to_string(should[:negate_destination])) unless should[:negate_destination].nil?

      builder.disabled(bool_to_string(should[:disable])) unless should[:disable].nil?
    end
  end
end
