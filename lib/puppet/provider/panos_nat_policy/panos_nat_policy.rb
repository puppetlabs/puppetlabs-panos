require 'puppet/provider/panos_provider'
require 'rexml/document'
require 'builder'

# Implementation for the panos_NAT_policy type using the Resource API.
class Puppet::Provider::PanosNatPolicy::PanosNatPolicy < Puppet::Provider::PanosProvider
  def munge(entry)
    entry[:bi_directional] = string_to_bool(entry[:bi_directional]) unless entry[:bi_directional].nil?
    entry
  end

  def validate_should(should)
    if should[:fallback_address_type] == 'translated-address' && !should[:fallback_interface].nil?
      raise Puppet::ResourceError, 'Please do not supply a fallback interface when the fallback address type is `translated-address`'
    end
    if should[:fallback_address_type] == 'interface-address' && !should[:fallback_address].nil?
      raise Puppet::ResourceError, 'Please do not supply a fallback address when the fallback address type is `interface-address`'
    end
    if should[:bi_directional] == true && !should[:destination_translated_address].nil?
      raise Puppet::ResourceError, 'Bi-directional option not applicable to a rule with both source and destination translation'
    end
    if should[:nat_type] == 'nptv6' && should[:source_translation_type] != 'static-ip'
      raise Puppet::ResourceError, 'Static Ip Source Address Translation must be used with `nptv6` NAT types'
    end
    if should[:source_translation_type] == 'static-ip' && should[:source_translated_static_address].nil? # rubocop:disable Style/GuardClause # line too long
      raise Puppet::ResourceError, 'You must specify the translated addresses when using Static Ip Source Address Translation'
    end
  end

  def xml_from_should(name, should)
    builder = Builder::XmlMarkup.new
    builder.entry('name' => name) do
      if should[:source_translation_type]
        builder.__send__('source-translation') do
          builder.__send__(should[:source_translation_type]) do
            if should[:fallback_address_type]
              builder.__send__('fallback') do
                builder.__send__(should[:fallback_address_type]) do
                  if should[:fallback_address_type] == 'interface-address'
                    builder.interface(should[:fallback_interface])
                    builder.__send__(should[:fallback_interface_ip_type], should[:fallback_interface_ip])
                  elsif should[:fallback_address_type] == 'translated-address'
                    should[:fallback_address].each do |addr|
                      builder.member(addr)
                    end
                  end
                end
              end
            end
            if should[:source_translation_type] == 'static-ip'
              builder.__send__('bi-directional', 'yes') if should[:bi_directional]
              builder.__send__('translated-address', should[:source_translated_static_address]) if should[:source_translated_static_address]
            elsif should[:source_translated_address]
              builder.__send__('translated-address') do
                should[:source_translated_address].each do |addr|
                  builder.member(addr)
                end
              end
            elsif should[:SAT_interface]
              builder.__send__('interface-address') do
                builder.ip(should[:SAT_interface_ip])
                builder.interface(should[:SAT_interface])
              end
            end
          end
        end
      end
      if should[:destination_zones]
        builder.to do
          should[:destination_zones].each do |zone|
            builder.member(zone)
          end
        end
      end
      unless should[:destination_translated_address].nil?
        builder.__send__('destination-translation') do
          builder.__send__('translated-port', should[:destination_translated_port]) if should[:destination_translated_port]
          builder.__send__('translated-address', should[:destination_translated_address]) if should[:destination_translated_address]
        end
      end
      if should[:source_zones]
        builder.from do
          should[:source_zones].each do |zone|
            builder.member(zone)
          end
        end
      end
      if should[:source_address]
        builder.source do
          should[:source_address].each do |addr|
            builder.member(addr)
          end
        end
      end
      if should[:destination_address]
        builder.destination do
          should[:destination_address].each do |addr|
            builder.member(addr)
          end
        end
      end
      build_tags(builder, should) if should[:tags]
      builder.service(should[:service]) if should[:service]
      builder.description(should[:description]) if should[:description]
      builder.__send__('to-interface', should[:destination_interface]) if should[:destination_interface]
      builder.__send__('nat-type', should[:nat_type]) if should[:nat_type]
      builder.__send__('disabled', 'yes') if should[:disabled]
    end
  end
end
