#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

$KCODE = 'UTF8'

require 'csv'
require 'dbf'

require 'active_support/multibyte'
require 'active_support/core_ext/string/multibyte'
require '../../lib/canonicalizer.rb'

dbf_filename = ARGV[0]
if dbf_filename.nil?
  STDERR.write("Usage: scrape-quebec-street-names.rb DBF-FILE\n")
  exit(1)
end

streets = {}

STDERR.write("Parsing DBF #{dbf_filename.inspect} (each dot means 50 records)...\n")
STDERR.flush

n = 0

features = DBF::Table.new(dbf_filename)
features.each do |feature|
  street_full_name = feature.l_stname_c
  city = feature.l_placenam

  streets_with_name = (streets[street_full_name] ||= {})
  streets_with_name[city] = true

  n += 1
  if n == 50
    n = 0
    STDERR.write('.')
    STDERR.flush
  end
end

STDERR.write("\nOutputting CSV...\n")
STDERR.flush

CSV::Writer.generate(STDOUT) do |csv|
  streets.each do |street_full_name, cities|
    street_type, street_name = street_full_name.split(' ', 2)

    street_type = '' if street_type.nil?
    if street_name.nil?
      STDERR.write("Skipped: #{street_full_name} (#{cities.keys.inspect})\n")
      STDERR.flush
      next
      street_type, street_name = '', street_type
    end

    cities.each do |city, _|
      csv << [ street_type, street_name, city ]
    end
  end
end
