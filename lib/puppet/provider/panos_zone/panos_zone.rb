require 'puppet/provider/panos_provider'
require 'rexml/document'
require 'builder'

# Implementation for the panos_tags type using the Resource API.
class Puppet::Provider::PanosZone::PanosZone < Puppet::Provider::PanosProvider
  def munge(entry)
    bool_attrs = [:enable_user_identification, :enable_packet_buffer_protection, :nsx_service_profile]
    bool_attrs.each do |attr|
      if entry.key? attr
        entry[attr] = string_to_bool(entry[attr])
      end
    end
    entry
  end

  def xml_from_should(name, should)
    builder = Builder::XmlMarkup.new
    builder.entry('name' => name) do
      builder.__send__('network') do
        if should[:nsx_service_profile]
          builder.__send__('virtual-wire')
        elsif should[:interfaces].nil?
          builder.__send__(should[:network])
        else
          builder.__send__(should[:network]) do
            should[:interfaces].each do |interface|
              builder.member(interface)
            end
          end
        end
        builder.__send__('enable-packet-buffer-protection', bool_to_string(should[:enable_packet_buffer_protection])) if should[:enable_packet_buffer_protection]
        builder.__send__('zone-protection-profile', should[:zone_protection_profile]) unless should[:zone_protection_profile].nil?
        builder.__send__('log-setting', should[:log_setting]) unless should[:log_setting].nil?
      end
      if !should[:include_list].nil? || !should[:exclude_list].nil?
        builder.__send__('user-acl') do
          unless should[:include_list].nil?
            builder.__send__('include-list') { should[:include_list].each { |included| builder.member(included) } }
          end
          unless should[:exclude_list].nil?
            builder.__send__('exclude-list') { should[:exclude_list].each { |excluded| builder.member(excluded) } }
          end
        end
      end
      builder.__send__('enable-user-identification', bool_to_string(should[:enable_user_identification])) if should[:enable_user_identification]
      builder.__send__('nsx-service-profile', bool_to_string(should[:nsx_service_profile])) if should[:nsx_service_profile]
    end
  end

  def validate_should(should)
    if should[:nsx_service_profile] == true && (!should[:interfaces].nil? || should[:network].nil?)
      raise Puppet::ResourceError, 'Interfaces cannot be used with NSX Service Profile, and a network type must be provided.'
    end
    if should[:network] == 'tunnel' && !should[:interfaces].nil? # rubocop:disable Style/GuardClause
      raise Puppet::ResourceError, 'Interfaces cannot be used when `network` is set to `tunnel`.'
    end
  end
end
