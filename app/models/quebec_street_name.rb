class QuebecStreetName < ActiveRecord::Base
  # no validates_uniqueness_of -- we only import data once, and we need it fast
end
