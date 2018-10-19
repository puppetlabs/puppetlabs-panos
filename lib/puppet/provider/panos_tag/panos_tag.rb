require_relative '../panos_provider'
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
      'olive' => 'color17',
      # color18 does not appear in 8.1
      'maroon' => 'color19',
      'red-orange' => 'color20',
      'yellow-orange' => 'color21',
      'forest green' => 'color22',
      'turquoise blue' => 'color23',
      'azure blue' => 'color24',
      'cerulean blue' => 'color25',
      'midnight blue' => 'color26',
      'medium blue' => 'color27',
      'cobalt blue' => 'color28',
      'violet blue' => 'color29',
      'blue violet' => 'color30',
      'medium violet' => 'color31',
      'medium rose' => 'color32',
      'lavender' => 'color33',
      'orchid' => 'color34',
      'thistle' => 'color35',
      'peach' => 'color36',
      'salmon' => 'color37',
      'magenta' => 'color38',
      'red violet' => 'color39',
      'mahogany' => 'color40',
      'burnt sienna' => 'color41',
      'chestnut' => 'color42',
    }
    @color_from_code = @code_from_color.invert
  end

  def canonicalize(_context, resources)
    resources.each do |resource|
      resource[:color] = resource[:color].downcase if resource[:color]
    end
    resources
  end

  def validate_should(should)
    return unless should.key? :color
    raise Puppet::ResourceError, 'Please use one of the existing Palo Alto colors.' unless @code_from_color.key? should[:color]
  end

  def munge(entry)
    entry[:color] = @color_from_code[entry[:color]] if entry[:color]
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
