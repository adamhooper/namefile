require 'csv'

class OrderOfCanadaDirectory
  include Singleton
  attr_reader(:data)

  def data
    return @data if @data
    @data = parse_csv("#{File.dirname(__FILE__)}/../db/order-of-canada.csv")
  end

  def awards_for_last_name(name)
    data[name]
  end

  protected

  def parse_csv(filename)
    data = {}

    CSV.open(filename, 'r') do |row|
      last_name = row[0]
      name = row[1]
      city = row[2]
      award = row[3]

      data[last_name] ||= []

      data[last_name] << { :name => row[1], :city => row[2], :award => row[3] }
    end

    data
  end
end
