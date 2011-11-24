require 'csv'

class CsvNameMap
  def initialize(file, headers)
    load_records(file, headers)
  end

  def find_record(last_name)
    key = last_name_to_key(last_name)
    @records[key] && @records[key].first
  end

  def find_records(last_name)
    key = last_name_to_key(last_name)
    @records[key]
  end

  protected

  def last_name_to_key(last_name)
    last_name.to_s.strip.downcase
  end

  def load_records(file, headers)
    headers = sanitize_headers(headers)

    @records = {}

    if String === file
      file = File.open(file, 'rb')
    end

    csv = FasterCSV.new(file, :headers => headers, :skip_blanks => true, :header_converters => :symbol)
    csv.each do |row|
      key = last_name_to_key(row[:last_name])

      @records[key] ||= []
      @records[key] << row
    end
  end

  def sanitize_headers(headers)
    if headers.find('last_name') == nil
      raise ArgumentError.new("Headers needs a last_name, but only has: #{headers.inspect}")
    end
    headers
  end
end
