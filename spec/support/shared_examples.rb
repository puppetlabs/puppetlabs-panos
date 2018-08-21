RSpec.shared_examples 'xml_from_should(name, should)' do |test_data, provider|
  test_data.each do |test|
    it "creates expected XML for `#{test[:desc]}`" do
      expect(provider.xml_from_should(test[:attrs][:name], test[:attrs])).to eq(test[:xml].gsub(%r{\n(\s*[^<])?}, ''))
    end
  end
end

RSpec.shared_examples 'munge(entry)' do |test_data, provider|
  test_data.each do |test|
    it "executes correct munge for `#{test[:desc]}`" do
      expect(provider.munge(test[:entry])).to eq(test[:munged_entry])
    end
  end
end

RSpec.shared_examples 'str_from_xml(xml)' do |test_data, provider|
  test_data.each do |test|
    it "executes correct conversion for `#{test[:desc]}`" do
      expect(provider.str_from_xml(test[:raw_xml])).to eq(test[:parsed_xml])
    end
  end
end
