require 'csv'

class QuebecTop1000Directory
  POPULATION_OF_QUEBEC = 7546131

  include Singleton
  attr_reader(:data)

  def data
    return @data if @data
    @data = parse_csv("#{File.dirname(__FILE__)}/../db/quebec-top1000.csv")
  end

  def ranking_data_for_last_name(last_name)
    key = last_name.downcase
    data[key]
  end

  protected

  def parse_csv(filename)
    data = {}

    CSV.open(filename, 'r') do |row|
      last_name = row[1]
      key = last_name.downcase
      population = (row[2].to_f / 100 * POPULATION_OF_QUEBEC).round(-3).to_i

      data[key] = { :last_name => row[1], :rank => row[0].to_i, :approximate_population => population }
    end

    data
  end
end
