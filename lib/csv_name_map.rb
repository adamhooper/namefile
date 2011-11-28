require 'csv'

class CsvNameMap
  def initialize(file, headers)
    @file = file
    @headers = headers
    @in_database = calculate_in_database
    load_records unless in_database?
  end

  def find_record(last_name)
    key = last_name_to_key(last_name)

    if in_database?
      model.where(:key => key).first
    else
      @records[key] && @records[key].first
    end
  end

  def find_records(last_name)
    key = last_name_to_key(last_name)

    if in_database?
      records = model.where(:key => key).all
      records.length > 0 ? records : nil
    else
      @records[key]
    end
  end

  def in_database?
    @in_database
  end

  protected

  def table_name
    String === @file ? File.basename(@file).split(/\./).first.gsub(/-/, '_') : nil
  end

  def model
    model_name = table_name.classify
    model_name.constantize
  end

  def calculate_in_database
    # Ideally we wouldn't return from an exception here, but we need to because
    # the model might not be loaded yet, so const_defined? will always return
    # false.
    return false if table_name.nil?
    begin
      model
      true
    rescue
      false
    end
  end

  def last_name_to_key(last_name)
    Canonicalizer.canonicalize(last_name).downcase
  end

  def load_records
    headers = sanitized_headers

    @records = {}

    file = @file
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

  def sanitized_headers
    if @headers.find('last_name') == nil
      raise ArgumentError.new("Headers needs a last_name, but only has: #{@headers.inspect}")
    end
    @headers
  end
end
