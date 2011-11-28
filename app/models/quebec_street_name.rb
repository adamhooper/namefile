class QuebecStreetName < ActiveRecord::Base
  # no validates_uniqueness_of -- we only import data once, and we need it fast

  default_scope order(:city, :last_name, :street_type)
end
