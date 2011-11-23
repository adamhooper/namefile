#!/usr/bin/env ruby

require 'scrape'

require 'csv'
require 'logger'
require 'uri'

class OrderOfCanadaParser < Parser
  def initialize(html)
    super(html)
  end

  def records
    @records ||= doc.css('table#qres tbody tr').collect do |tr|
      record = {}

      tds = tr.css('td')
      href = tds[0].css('a')[0].attribute('href').to_s
      href =~ /\bln=([^&]+)\b/

      record[:last_name] = $1
      record[:full_name] = tds[0].css('a')[0].content.strip
      record[:city] = tds[1].content.strip
      record[:award] = tds[2].content.strip

      record
    end
  end

  def total_pages
    return @total_pages if @total_pages

    text = doc.css('tfoot.pagination th:first')[0].content
    text.strip =~ /(\d+)-(\d+) \/ (\d+)/
    records_per_page = $2
    total_records = $3
    @total_pages = (total_records.to_f / records_per_page.to_f).ceil
  end
end

url = 'http://www.gg.ca/honours.aspx?q=&t=12&p=&c=&pg=#{page}&types=12'
fetcher = Fetcher.new(url, OrderOfCanadaParser)
fetcher.logger = Logger.new(STDERR)
CSV::Writer.generate(STDOUT) do |csv|
  fetcher.write_records_to_csv(csv, :flusher => STDOUT, :start_page => 1)
end
