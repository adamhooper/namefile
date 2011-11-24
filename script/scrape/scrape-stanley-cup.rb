#!/usr/bin/env ruby

require 'scrape'

require 'csv'
require 'logger'
require 'uri'

class StanleyCupParser < Parser
  IndexUrl = 'http://www.nhl.com/ice/page.htm?id=31103'

  def initialize(html)
    super(html)
  end

  def url_list
    return @url_list if @url_list

    a_list = doc.css('h1 a')
    hrefs = a_list.collect{ |a| a.attribute('href').to_s }

    @url_list = [ IndexUrl ] + hrefs
  end

  def records
    return @records if @records

    table = doc.css('h1 a').first.parent.parent.parent.parent.parent
    ret = []

    table.children.each do |tr|
      next if tr.css('h1').length > 0

      tds = tr>'td'
      name = tds[0].text.sub("\302\240", '').strip
      last_name = name.split(/ /).last
      cups = tds[1].text.sub("\302\240", '').strip
      cups.split(/;\s*/).each do |cups_with_team|
        team = nil
        cups_with_team.split(/,\s*/).each do |year|
          year = year.strip
          if year.split(/\s+/).length > 1
            parts = year.split(/\s+/)
            team = parts[0..-2].join(' ')
            year = parts[-1]
          end

          ret << [ last_name, name, team, year ]
        end
      end
    end

    @records = ret
  end
end

fetcher = Fetcher.new(StanleyCupParser::IndexUrl, StanleyCupParser)
fetcher.logger = Logger.new(STDERR)
CSV::Writer.generate(STDOUT) do |csv|
  fetcher.write_records_to_csv(csv, :flusher => STDOUT)
end
