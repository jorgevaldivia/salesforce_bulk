require 'csv'

module SalesforceBulk
  module Helper
    extend self

    CSV_OPTIONS = {
      col_sep: ',',
      quote_char: '"',
      force_quotes: true,
    }

    def records_to_csv records
      file_mock = StringIO.new
      csv_client = CSV.new(file_mock, CSV_OPTIONS)
      all_headers = []
      all_rows = []
      records.each do |hash|
        row = CSV::Row.new([],[],false)
        to_store = hash.inject({}) do |h, (k, v)|
          h[k] = v.class == Array ? v.join(';') : v
          h
        end
        row << to_store
        all_headers << row.headers
        all_rows << row
      end
      csv_client << all_headers.flatten!.uniq!
      all_rows.each do |row|
        csv_client << row.fields(*all_headers)
      end
      file_mock.string
    end
  end
end