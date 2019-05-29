#!/opt/puppetlabs/puppet/bin/ruby

require 'json'
require 'nori'
require 'rexml/document'
require_relative '../lib/puppet/util/task_helper'

task = Puppet::Util::TaskHelper.new('panos')
result = {}

def build_xml(command)
  # Build XML from each element in CLI command.  Values are delimited by <>
  elements = command.split
  # First command becomes the root of the XML document
  root = elements.shift
  raise 'CLI commands cannot start with a value' if root.start_with?('<')
  doc = REXML::Document.new
  doc.add_element root
  elements.each do |element|
    # Grab the last child or root of the document for appending
    previous = doc.root.get_elements('.//[last()]')[-1]
    previous = doc.root if previous.nil?
    # Values are input as text (or attributes which this currently doesn't do)
    if element.start_with?('<')
      previous.text = element.gsub(%r{^<|>$}, '')
    else
      previous.add_element element
    end
  end
  doc
end

def command_xml(command)
  # Check if command is already XML
  doc = REXML::Document.new(command)
  # REXML accepts plain strings as XML for some reason - make sure it really is
  if doc.root.nil?
    # Attempt to convert CLI to XML
    build_xml(command)
  else
    # Command is XML format - carry on
    command
  end
rescue REXML::ParseException
  # Attempt to convert CLI to XML
  build_xml(command)
end

begin
  op_command = command_xml(task.params['command']).to_s
  result[:sent_xml] = op_command
  # Send the XML to the device
  rtn = task.transport.op_command(op_command)
  result[:status] = 'success'
  if task.params['output'] == 'xml'
    result[:results] = rtn.to_s
  else
    # Convert XML to JSON
    parser = Nori.new(parser: :rexml)
    result[:results] = parser.parse(rtn.to_s).to_json
  end
rescue Exception => e # rubocop:disable Lint/RescueException
  result[:_error] = { msg: e.message,
                      kind: 'puppetlabs-panos/unknown',
                      details: {
                        class: e.class.to_s,
                        backtrace: e.backtrace,
                      } }
  result[:status] = 'failure'
end

if result[:status] == 'success' && task.params['raw']
  puts result[:results]
else
  puts result.to_json
end
