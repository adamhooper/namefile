class ImportCsvQuebecStreetNames < ActiveRecord::Migration
  def up
    create_table(:quebec_street_names) do |t|
      t.string(:key)
      t.string(:street_type)
      t.string(:last_name)
      t.string(:city)
    end

    csv_filename = "#{File.dirname(__FILE__)}/../quebec-street-names.csv"
    FasterCSV.foreach(csv_filename) do |row|
      street_type = row[0].to_s
      last_name = row[1].to_s
      city = row[2].to_s
      key = Canonicalizer.canonicalize(last_name).downcase

      execute "INSERT INTO quebec_street_names(key, street_type, last_name, city) VALUES (#{quote(key)}, #{quote(street_type)}, #{quote(last_name)}, #{quote(city)})"
    end

    add_index(:quebec_street_names, :key)
  end

  def down
    drop_table(:quebec_street_names)
  end
end
