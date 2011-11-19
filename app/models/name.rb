class Name < ActiveRecord::Base
  validates_uniqueness_of(:last_name)

  def orders_of_canada
    OrderOfCanadaDirectory.instance.awards_for_last_name(last_name)
  end

  def quebec_top1000_ranking
    QuebecTop1000Directory.instance.ranking_data_for_last_name(last_name)
  end

  def to_param
    last_name
  end
end
