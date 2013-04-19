#encoding: utf-8
require 'spec_helper'

describe SalesforceBulk::Helper do
  describe '.records_to_csv' do
    it 'should return valid csv for basic records' do
      input = [
        {'Title' => 'Awesome Title', 'Name' => 'A name'},
        {'Title' => 'A second Title', 'Name' => 'A second name'},
      ]

      expected_csv = "\"Title\",\"Name\"\n" \
      "\"Awesome Title\",\"A name\"\n" \
      "\"A second Title\",\"A second name\"\n"
      expect(described_class.records_to_csv(input)).to eq(expected_csv)
    end

    it 'should return valid csv when first row misses a key' do
      input = [
        {'Title' => 'Awesome Title', 'Name' => 'A name'},
        {'Title' => 'A second Title', 'Name' => 'A second name', 'Something' => 'Else'},
      ]

      expected_csv = "\"Title\",\"Name\",\"Something\"\n" \
      "\"Awesome Title\",\"A name\",\"\"\n" \
      "\"A second Title\",\"A second name\",\"Else\"\n"
      expect(described_class.records_to_csv(input)).to eq(expected_csv)
    end

    it 'should return valid csv when order of keys varies' do
      input = [
        {'Title' => 'Awesome Title', 'Name' => 'A name'},
        {'Name' => 'A second name', 'Title' => 'A second Title'},
      ]

      expected_csv = "\"Title\",\"Name\"\n" \
      "\"Awesome Title\",\"A name\"\n" \
      "\"A second Title\",\"A second name\"\n"
      expect(described_class.records_to_csv(input)).to eq(expected_csv)
    end
  end
end