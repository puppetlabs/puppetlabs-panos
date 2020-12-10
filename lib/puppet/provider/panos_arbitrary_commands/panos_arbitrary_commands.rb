# frozen_string_literal: true

require 'puppet/resource_api/simple_provider'

# provider to handle arbitrary configuration commands against a PANOS device using the Resource API.
class Puppet::Provider::PanosArbitraryCommands::PanosArbitraryCommands < Puppet::ResourceApi::SimpleProvider
  def initialize
    require 'rexml/xpath'
    require 'builder'
  end

  # to ensure that the manifest xml matches the API format
  #
  # e.g.
  #     <entry admin='admin'>
  #       <foo>bar</bar>
  #     </entry>
  # becomes:
  #     <entry><foo>bar</bar></entry>
  def canonicalize(_context, resources)
    resources.each do |resource|
      resource[:xml] = str_from_xml(resource[:xml])
    end

    resources
  end

  def get(context, xpaths = nil)
    return [] if xpaths.nil?
    results = []
    config = context.transport.get_config('/config/' + xpaths.first) unless xpaths.first.nil?
    if xpaths.first
      config.elements.collect('/response/result') do |entry| # rubocop:disable Style/CollectionMethods
        xml = str_from_xml(entry.to_s)

        results << {
          xpath:  xpaths.first,
          ensure: 'present',
          xml:    xml,
        }
      end
    end
    results
  end

  def create(context, xpath, should)
    begin
      should = REXML::Document.new should[:xml]
    rescue REXML::ParseException => parse_exception
      raise Puppet::ResourceError, parse_exception.message
    end

    context.transport.set_config('/config/' + xpath, should)
  end

  def update(context, xpath, should)
    begin
      should = REXML::Document.new should[:xml]
    rescue REXML::ParseException => parse_exception
      raise Puppet::ResourceError, parse_exception.message
    end

    context.transport.edit_config('/config/' + xpath, should)
  end

  def delete(context, xpath)
    context.transport.delete_config('/config/' + xpath)
  end

  def str_from_xml(xml)
    xml.to_s
       .gsub(%r{<result.*?[^>)]>}, '') # cleaning out the start of the result tags
       .gsub(%r{</result>}, '') # cleaning the closing result tags
       .gsub(%r{admin=(?:'|")[a-zA-Z0-9]*(?:'|")}, '') # removing the `admin` attributes
       .gsub(%r{time=(?:'|")\d{4}\/\d{2}\/\d{2} \d{2}:\d{2}:\d{2}(?:'|")}, '') # removing the `time` attributes
       .gsub(%r{dirtyId=(?:'|")\d*(?:'|")}, '') # removing the `dirtyId` attributes
       .gsub(%r{\n(\s*[^<])?}, '') # removing new lines and extra spaces
       .tr("'", '"') # replacing the \' with "
       .gsub(%r{\s{2,}}, ' ') # removing extra spaces
       .gsub(%r{\s*(/)?>}, '\1>') # cleaning the extra spaces before a close `>` and self close `/>`
  end
end
