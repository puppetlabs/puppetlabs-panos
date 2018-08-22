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

RSpec.shared_examples '`name` exceeds 63 characters' do |type|
  context 'when `name` exceeds 63 characters' do
    let(:name) { 'longer string exceeding the 63 character limit on a PAN-OS 8.1.0' }

    it 'throws an error' do
      expect(name.length).to eq 64

      expect {
        Puppet::Type.type(type).new(
          name: name,
        )
      }.to raise_error Puppet::ResourceError
    end
  end
end

RSpec.shared_examples '`name` does not exceed 63 characters' do |type|
  context 'when `name` does not exceed 63 characters' do
    let(:name) { 'the shorter string within a 63 character limit for PAN-OS 8.1.0' }

    it 'does not throw an error' do
      expect(name.length).to eq 63

      expect {
        Puppet::Type.type(type).new(
          name: name,
        )
      }.not_to raise_error
    end
  end
end
