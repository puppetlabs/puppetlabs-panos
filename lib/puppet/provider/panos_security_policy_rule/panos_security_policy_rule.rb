require 'puppet/provider/panos_provider'
require 'rexml/document'
require 'builder'

# Implementation for the panos_security_policy_rule type using the Resource API.
class Puppet::Provider::PanosSecurityPolicyRule::PanosSecurityPolicyRule < Puppet::Provider::PanosProvider
  def munge(entry)
    none_attrs = [:profile_type, :qos_type, :anti_virus_profile,
                  :url_filtering_profile, :data_filtering_profile,
                  :file_blocking_profile, :spyware_profile, :vulnerability_profile,
                  :wildfire_analysis_profile]
    none_attrs.each do |attr|
      if entry.key?(attr) && entry[attr].nil?
        entry[attr] = 'none'
      end
    end
    bool_attrs = [:icmp_unreachable, :log_start, :log_end, :disable_server_response_inspection, :negate_source, :negate_destination, :disable]
    bool_attrs.each do |attr|
      if entry.key? attr
        entry[attr] = string_to_bool(entry[attr])
      end
    end
    entry
  end

  def validate_should(should)
    if should[:rule_type] == 'intrazone'
      if should[:destination_zones].size > 1 && should[:destination_zones].first != 'any'
        raise Puppet::ResourceError, 'Destination zone can only be [`any`] for rule_type `intrazone`.'
      end
    end
    if should[:profile_type] != 'profiles'
      if should[:anti_virus_profile]
        raise Puppet::ResourceError, '`anti_virus_profile` can only be supplied for `profile_type` `profiles`.'
      end
      if should[:url_filtering_profile]
        raise Puppet::ResourceError, '`url_filtering_profile` can only be supplied for `profile_type` `profiles`.'
      end
      if should[:data_filtering_profile]
        raise Puppet::ResourceError, '`data_filtering_profile` can only be supplied for `profile_type` `profiles`.'
      end
      if should[:file_blocking_profile]
        raise Puppet::ResourceError, '`file_blocking_profile` can only be supplied for `profile_type` `profiles`.'
      end
      if should[:spyware_profile]
        raise Puppet::ResourceError, '`spyware_profile` can only be supplied for `profile_type` `profiles`.'
      end
      if should[:vulnerability_profile]
        raise Puppet::ResourceError, '`vulnerability_profile` can only be supplied for `profile_type` `profiles`.'
      end
      if should[:wildfire_analysis_profile]
        raise Puppet::ResourceError, '`wildfire_analysis_profile` can only be supplied for `profile_type` `profiles`.'
      end
    elsif should[:profile_type] != 'group' && should[:group_profile]
      raise Puppet::ResourceError, '`group_profile` can only be supplied for `profile_type` `group`.'
    end
    if should[:qos_type] == 'ip-dscp' && !should[:ip_dscp]
      raise Puppet::ResourceError, '`ip_dscp` needs to be supplied for `qos_type` `ip_dscp`.'
    end
    if should[:qos_type] == 'ip-precedence' && !should[:ip_precedence]
      raise Puppet::ResourceError, '`ip_precedence` needs to be supplied for `qos_type` `ip_precedence`.'
    end
    if should[:qos_type] != 'ip-dscp' && should[:ip_dscp]
      raise Puppet::ResourceError, '`ip_dscp` can only be supplied for `qos_type` `ip_dscp`.'
    end
    if should[:qos_type] != 'ip-precedence' && should[:ip_precedence]
      raise Puppet::ResourceError, '`ip_precedence` can only be supplied for `qos_type` `ip_precedence`.'
    end
    if should[:icmp_unreachable] == true && (should[:action] == 'allow' || should[:action] == 'deny')
      raise Puppet::ResourceError, "\`icmp_unreachable\` cannot be \`#{should[:icmp_unreachable]}\` for \`action\` \`#{should[:action]}\`."
    end
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
      builder.application do
        should[:applications].each do |application|
          builder.member(application)
        end
      end
      builder.service do
        should[:services].each do |service|
          builder.member(service)
        end
      end
      builder.__send__('hip-profiles') do
        should[:hip_profiles].each do |profile|
          builder.member(profile)
        end
      end

      builder.action(should[:action])

      builder.__send__('rule-type', should[:rule_type]) if should[:rule_type]

      builder.__send__('icmp-unreachable', bool_to_string(should[:icmp_unreachable])) unless should[:icmp_unreachable].nil?

      if should[:disable_server_response_inspection]
        builder.option do
          builder.__send__('disable-server-response-inspection', bool_to_string(should[:disable_server_response_inspection]))
        end
      end

      builder.schedule(should[:schedule_profile]) if should[:schedule_profile]

      if should[:profile_type] == 'profiles'
        builder.__send__('profile-setting') do
          if should[:anti_virus_profile] || should[:url_filtering_profile] || should[:data_filtering_profile] || should[:file_blocking_profile] || should[:spyware_profile] ||
             should[:vulnerability_profile] || should[:wildfire_analysis_profile]
            builder.__send__(should[:profile_type]) do
              if should[:anti_virus_profile] && should[:anti_virus_profile] != 'none'
                builder.virus do
                  builder.member(should[:anti_virus_profile])
                end
              end
              if should[:url_filtering_profile] && should[:url_filtering_profile] != 'none'
                builder.__send__('url-filtering') do
                  builder.member(should[:url_filtering_profile])
                end
              end
              if should[:data_filtering_profile] && should[:data_filtering_profile] != 'none'
                builder.__send__('data-filtering') do
                  builder.member(should[:data_filtering_profile])
                end
              end
              if should[:file_blocking_profile] && should[:file_blocking_profile] != 'none'
                builder.__send__('file-blocking') do
                  builder.member(should[:file_blocking_profile])
                end
              end
              if should[:spyware_profile] && should[:spyware_profile] != 'none'
                builder.__send__('spyware') do
                  builder.member(should[:spyware_profile])
                end
              end
              if should[:vulnerability_profile] && should[:vulnerability_profile] != 'none'
                builder.__send__('vulnerability') do
                  builder.member(should[:vulnerability_profile])
                end
              end
              if should[:wildfire_analysis_profile] && should[:wildfire_analysis_profile] != 'none'
                builder.__send__('wildfire-analysis') do
                  builder.member(should[:wildfire_analysis_profile])
                end
              end
            end
          else
            builder.__send__(should[:profile_type])
          end
        end
      elsif should[:profile_type] == 'group'
        builder.__send__('profile-setting') do
          if should[:group_profile]
            builder.__send__(should[:profile_type]) do
              builder.member(should[:group_profile])
            end
          else
            builder.__send__(should[:profile_type])
          end
        end
      end

      builder.__send__('log-setting', should[:log_setting]) if should[:log_setting]

      builder.__send__('log-start', bool_to_string(should[:log_start])) unless should[:log_start].nil?

      builder.__send__('log-end', bool_to_string(should[:log_end])) unless should[:log_end].nil?

      if should[:qos_type]
        builder.qos do
          if should[:qos_type] == 'ip-dscp'
            builder.marking do
              builder.__send__(should[:qos_type], should[:ip_dscp])
            end
          elsif should[:qos_type] == 'ip-precedence'
            builder.marking do
              builder.__send__(should[:qos_type], should[:ip_precedence])
            end
          elsif should[:qos_type] == 'follow-c2s-flow'
            builder.marking do
              builder.__send__(should[:qos_type])
            end
          end
        end
      end

      builder.description(should[:description]) if should[:description]

      build_tags(builder, should)

      builder.__send__('negate-source', bool_to_string(should[:negate_source])) unless should[:negate_source].nil?

      builder.__send__('negate-destination', bool_to_string(should[:negate_destination])) unless should[:negate_destination].nil?

      builder.disabled(bool_to_string(should[:disable])) unless should[:disable].nil?
    end
  end
end
