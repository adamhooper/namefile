#!/usr/bin/env ruby

require 'scrape'

require 'csv'
require 'logger'
require 'uri'

class CanadiensParser < Parser
  Url = 'http://canadiens.nhl.com/club/historicalplayers.htm?letter=#{letter}'
  IndexUrl = Url.sub('#{letter}', 'A')
  PlayerUrl = 'http://canadiens.nhl.com#{part}'
  WhitespaceRegex = /(\s|\302\240)+/

  def initialize(html)
    super(html)
  end

  def url_list
    return @url_list if @url_list

    @url_list = ('A'..'Z').collect { |c| Url.sub('#{letter}', c) }
  end

  def records
    @records ||= doc.css('table.data').css('tr.rwEven, tr.rwOdd').collect do |tr|
      tds = tr.css('td')

      href = tds[0].css('a').attribute('href')
      url = PlayerUrl.sub('#{part}', href)
      description = tds[0].text.strip
      team = tds[1].text.strip
      date_of_birth = tds[2].text.strip
      place_of_birth = tds[3].text.strip

      description.gsub!(WhitespaceRegex, ' ')
      description =~ /([^,]+), *(.+?) *\((\w+)\)/
      last_name = $1
      full_name = "#{$2} #{last_name}"
      position = $3

      [ last_name, full_name, position, team, date_of_birth, place_of_birth, url ]
    end
  end
end

fetcher = Fetcher.new(CanadiensParser::IndexUrl, CanadiensParser)
fetcher.logger = Logger.new(STDERR)
CSV::Writer.generate(STDOUT) do |csv|
  fetcher.write_records_to_csv(csv, :flusher => STDOUT)
end
