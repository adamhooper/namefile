class Name < ActiveRecord::Base
  POPULATION_OF_QUEBEC = 7546131
  MONTREAL_METRO_LINE_COLORS = {
    'Blue' => '#1082ce',
    'Yellow' => '#fcd205',
    'Orange' => '#f47216',
    'Green' => '#00a650'
  }

  validates_uniqueness_of(:last_name)

  OrdersOfCanada = CsvNameMap.new("#{File.dirname(__FILE__)}/../../db/order-of-canada.csv", %w(last_name full_name city award))
  QuebecTop1000 = CsvNameMap.new("#{File.dirname(__FILE__)}/../../db/quebec-top1000.csv", %w(rank last_name percent))
  QuebecStreetNames = CsvNameMap.new("#{File.dirname(__FILE__)}/../../db/quebec-street-names.csv", %w(street_type last_name city))
  StanleyCupWinners = CsvNameMap.new("#{File.dirname(__FILE__)}/../../db/stanley-cup-winners.csv", %w(last_name full_name team year))
  MontrealMetroStations = CsvNameMap.new("#{File.dirname(__FILE__)}/../../db/montreal-metro-stations.csv", %w(last_name station_name metro_lines_string))

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

  def quebec_street_names
    QuebecStreetNames.find_records(last_name)
  end

  def montreal_metro_station
    record = MontrealMetroStations.find_record(last_name)
    if record
      record[:metro_lines] = record[:metro_lines_string].split(/\s*;\s*/).collect do |line|
        { :name => line, :color => MONTREAL_METRO_LINE_COLORS[line] }
      end
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

    if data = montreal_metro_station
      results << {
        :key => :montreal_metro_station,
        :data => data,
        :points => 500
      }
    end

    if data = quebec_street_names
      results << {
        :key => :quebec_street_names,
        :data => data,
        :points => 250 * data.length
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

  def capitalized_last_name
    return @capitalized_last_name if @capitalized_last_name

    candidates = {}
    data_set_results.each do |result|
      if Array === result[:data]
        result[:data].each do |record|
          candidates[record[:last_name]] ||= 0
          candidates[record[:last_name]] += 1
        end
      else
        candidates[result[:last_name]] ||= 0
        candidates[result[:last_name]] += 1
      end
    end

    @capitalized_last_name = if candidates.empty?
      last_name
    else
      best = nil
      best_count = 0
      candidates.each do |current, count|
        if count > best_count
          best = current
          best_count = count
        end
      end
      best
    end
  end

  def to_param
    last_name
  end
end
