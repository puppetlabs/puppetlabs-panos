# a simple xpath matcher for REXML documents
# inspired by: https://gist.github.com/pxlpnk/7223848
RSpec::Matchers.define :have_xml do |xpath, text|
  match do |doc|
    doc = REXML::Document.new(doc) if doc.is_a? String
    nodes = doc.elements.to_a(xpath)
    @nodes_empty = nodes.empty?
    return false if @nodes_empty
    return true unless text
    nodes.any? do |node|
      node.text == text
    end
  end

  failure_message do |doc|
    message = if @nodes_empty
                "expected to find xml tag #{xpath} in:\n"
              else
                "expected to find xml tag #{xpath} with #{text.inspect} in:\n"
              end
    doc.write(message, 2)
    message
  end

  failure_message_when_negated do |doc|
    message = if !@nodes_empty && text.nil?
                "found xml tag #{xpath} in:\n"
              else
                "xml tag #{xpath} matches #{text.inspect} in:\n"
              end
    doc.write(message, 2)
    message
  end

  description do
    if text
      "have xml tag #{xpath} with value #{text.inspect}"
    else
      "have xml tag #{xpath}"
    end
  end
end
