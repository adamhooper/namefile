class Name < ActiveRecord::Base
  POPULATION_OF_QUEBEC = 7546131

  validates_uniqueness_of(:last_name)

  OrdersOfCanada = CsvNameMap.new("#{File.dirname(__FILE__)}/../../db/order-of-canada.csv", %w(last_name full_name city award))
  QuebecTop1000 = CsvNameMap.new("#{File.dirname(__FILE__)}/../../db/quebec-top1000.csv", %w(rank last_name percent))
  StanleyCupWinners = CsvNameMap.new("#{File.dirname(__FILE__)}/../../db/stanley-cup-winners.csv", %w(last_name full_name team year))

  def orders_of_canada
    OrdersOfCanada.find_records(last_name)
  end

  def quebec_top1000_ranking
    record = QuebecTop1000.find_record(last_name)
    if record
      record[:rank] = record[:rank].to_i
      record[:approximate_population] = (record[:percent].to_f / 100 * POPULATION_OF_QUEBEC).round(-3).to_i
      record
    end
  end

  def stanley_cup_winners
    StanleyCupWinners.find_records(last_name)
  end

  def data_set_results
    return @data_set_results if @data_set_results

    results = []

    if data = quebec_top1000_ranking
      results << {
        :key => :quebec_top1000_ranking,
        :data => data,
        :points => 1001 - data[:rank]
      }
    end

    if data = orders_of_canada
      results << {
        :key => :orders_of_canada,
        :data => data,
        :points => data.length * 200
      }
    end

    if data = stanley_cup_winners
      results << {
        :key => :stanley_cup_winners,
        :data => data,
        :points => data.length * 333
      }
    end

    @data_set_results = results
  end

  def points
    @points ||= data_set_results.inject(0) { |s,v| s += v[:points] }
  end

  def to_param
    last_name
  end
end
