require_relative '../panos_provider'

# Implementation for the panos_profiles_url-Filtering type using the Resource API.
class Puppet::Provider::PanosProfilesUrlFiltering::PanosProfilesUrlFiltering < Puppet::Provider::PanosProvider
  def munge(entry)
    entry[:credential_mode] = 'disabled' if entry[:rule_type].nil?
    entry[:log_severity] = 'medium' if entry[:rule_type].nil?
    entry[:action] = 'block' if entry[:rule_type].nil?
    entry
  end

  def xml_from_should(name, should)
    builder = Builder::XmlMarkup.new
    builder.entry('name' => name) do
      builder.__send__('credential-enforcement') do
        builder.mode do
          builder.tag! should[:credential_mode], nil
        end
        unless should[:credential_block].nil?
          builder.block do
            should[:credential_block].each do |category|
              builder.member(category)
            end
          end
        end
        unless should[:credential_continue].nil?
          builder.continue do
            should[:credential_continue].each do |category|
              builder.member(category)
            end
          end
        end
        unless should[:credential_allow].nil?
          builder.allow do
            should[:credential_allow].each do |category|
              builder.member(category)
            end
          end
        end
        unless should[:credential_alert].nil?
          builder.alert do
            should[:credential_alert].each do |category|
              builder.member(category)
            end
          end
        end
        builder.__send__('log-severity', should[:log_severity])
      end
      unless should[:block].nil?
        builder.block do
          should[:block].each do |category|
            builder.member(category)
          end
        end
      end
      unless should[:continue].nil?
        builder.continue do
          should[:continue].each do |category|
            builder.member(category)
          end
        end
      end
      unless should[:allow].nil?
        builder.allow do
          should[:allow].each do |category|
            builder.member(category)
          end
        end
      end
      unless should[:alert].nil?
        builder.alert do
          should[:alert].each do |category|
            builder.member(category)
          end
        end
      end
      unless should[:override].nil?
        builder.override do
          should[:override].each do |category|
            builder.member(category)
          end
        end
      end
      unless should[:allow_list].nil?
        builder.__send__('allow-list') do
          should[:allow_list].each do |category|
            builder.member(category)
          end
        end
      end
      unless should[:block_list].nil?
        builder.__send__('block-list') do
          should[:block_list].each do |category|
            builder.member(category)
          end
        end
      end

      builder.action(should[:action])

      builder.description(should[:description]) if should[:description]
    end
  end
end
