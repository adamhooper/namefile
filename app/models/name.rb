class Name < ActiveRecord::Base
  validates_uniqueness_of(:last_name)

  def orders_of_canada
    OrderOfCanadaDirectory.instance.awards_for_last_name(last_name)
  end
end
