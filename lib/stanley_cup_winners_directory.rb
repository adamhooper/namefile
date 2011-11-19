require 'csv'

class StanleyCupWinnersDirectory
  include Singleton
  attr_reader(:data)

  def data
    return @data if @data
    @data = parse_csv("#{File.dirname(__FILE__)}/../db/stanley-cup-winners.csv")
  end

  def stanley_cup_winners_with_last_name(name)
    key = name.downcase
    data[key]
  end

  protected

  def parse_csv(filename)
    data = {}

    CSV.open(filename, 'r') do |row|
      name = row[0]
      last_name = name.split[-1]
      key = last_name.downcase

      data[key] ||= []
      data[key] << row[0]
    end

    data
  end
end
