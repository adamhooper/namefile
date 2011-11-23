class Name < ActiveRecord::Base
  POPULATION_OF_QUEBEC = 7546131

  validates_uniqueness_of(:last_name)

  OrdersOfCanada = CsvNameMap.new("#{File.dirname(__FILE__)}/../../db/order-of-canada.csv", %w(last_name full_name city award))
  QuebecTop1000 = CsvNameMap.new("#{File.dirname(__FILE__)}/../../db/quebec-top1000.csv", %w(rank last_name percent))
  StanleyCupWinners = CsvNameMap.new("#{File.dirname(__FILE__)}/../../db/stanley-cup-winners.csv", %w(last_name full_name))

  def orders_of_canada
    OrdersOfCanada.find_records(last_name)
  end

  def quebec_top1000_ranking
    record = QuebecTop1000.find_record(last_name)
    record[:rank] = record[:rank].to_i
    record[:approximate_population] = (record[:percent].to_f / 100 * POPULATION_OF_QUEBEC).round(-3).to_i
    record
  end

  def stanley_cup_winners
    StanleyCupWinners.find_records(last_name)
  end

  def to_param
    last_name
  end
end
