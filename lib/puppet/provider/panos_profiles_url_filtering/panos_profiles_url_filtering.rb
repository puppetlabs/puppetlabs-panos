require_relative '../panos_provider'

# Implementation for the panos_profiles_url-Filtering type using the Resource API.
class Puppet::Provider::PanosProfilesUrlFiltering::PanosProfilesUrlFiltering < Puppet::Provider::PanosProvider
  def validate_should(should); end

  def xml_from_should(name, should)
    should[:credential_mode] = 'disabled' if should[:credential_mode].nil?
    should[:log_severity] = 'medium' if should[:log_severity].nil?
    should[:action] = 'block' if should[:action].nil?

    builder = Builder::XmlMarkup.new
    builder.entry('name' => name) do
      builder.__send__('credential-enforcement') do
        builder.mode do
          builder.tag! should[:credential_mode], nil
        end
        if should[:credential_block]
          builder.block do
            should[:credential_block].each do |category|
              builder.member(category)
            end
          end
        end
        if should[:credential_continue]
          builder.continue do
            should[:credential_continue].each do |category|
              builder.member(category)
            end
          end
        end
        if should[:credential_allow]
          builder.allow do
            should[:credential_allow].each do |category|
              builder.member(category)
            end
          end
        end
        if should[:credential_alert]
          builder.alert do
            should[:credential_alert].each do |category|
              builder.member(category)
            end
          end
        end
        builder.__send__('log-severity', should[:log_severity])
      end
      if should[:block]
        builder.block do
          should[:block].each do |category|
            builder.member(category)
          end
        end
      end
      if should[:continue]
        builder.continue do
          should[:continue].each do |category|
            builder.member(category)
          end
        end
      end
      if should[:allow]
        builder.allow do
          should[:allow].each do |category|
            builder.member(category)
          end
        end
      end
      if should[:alert]
        builder.alert do
          should[:alert].each do |category|
            builder.member(category)
          end
        end
      end
      if should[:override]
        builder.override do
          should[:override].each do |category|
            builder.member(category)
          end
        end
      end
      if should[:allow_list]
        builder.__send__('allow-list') do
          should[:allow_list].each do |category|
            builder.member(category)
          end
        end
      end
      if should[:block_list]
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
