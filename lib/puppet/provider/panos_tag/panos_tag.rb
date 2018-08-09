require 'puppet/provider/panos_provider'
require 'rexml/document'
require 'builder'

# Implementation for the panos_tags type using the Resource API.
class Puppet::Provider::PanosTag::PanosTag < Puppet::Provider::PanosProvider
  def initialize
    @code_from_color = {
      'red' => 'color1',
      'green' => 'color2',
      'blue' => 'color3',
      'yellow' => 'color4',
      'copper' => 'color5',
      'orange' => 'color6',
      'purple' => 'color7',
      'gray' => 'color8',
      'light green' => 'color9',
      'cyan' => 'color10',
      'light gray' => 'color11',
      'blue gray' => 'color12',
      'lime' => 'color13',
      'black' => 'color14',
      'gold' => 'color15',
      'brown' => 'color16',
    }
    @color_from_code = @code_from_color.invert
  end

  def munge(entry)
    raise Puppet::ResourceError, 'Please use one of the existing Palo Alto colors.' unless @color_from_code.key? entry[:color]
    entry[:color] = @color_from_code[entry[:color]]
    entry
  end

  def xml_from_should(name, should)
    builder = Builder::XmlMarkup.new
    builder.entry('name' => name) do
      builder.color(@code_from_color[should[:color]]) if should.key? :color
      builder.comments(should[:comments]) if should.key? :comments
    end
  end
end
