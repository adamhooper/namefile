require 'csv'

class OrderOfCanadaDirectory
  include Singleton
  attr_reader(:data)

  def data
    return @data if @data
    @data = parse_csv("#{File.dirname(__FILE__)}/../db/order-of-canada.csv")
  end

  def awards_for_last_name(name)
    key = name.downcase
    data[key]
  end

  protected

  def parse_csv(filename)
    data = {}

    CSV.open(filename, 'r') do |row|
      last_name = row[0]
      key = last_name.downcase

      data[key] ||= []
      data[key] << { :last_name => row[0], :full_name => row[1], :city => row[2], :award => row[3] }
    end

    data
  end
end
