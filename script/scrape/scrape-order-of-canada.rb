#!/usr/bin/env ruby

require 'scrape'

require 'csv'
require 'logger'

class OrderOfCanadaParser < Parser
  Url = 'http://www.gg.ca/honours.aspx?q=&t=12&p=&c=&pg=#{page}&types=12'

  def initialize(html)
    super(html)
  end

  def records
    @records ||= doc.css('table#qres tbody tr').collect do |tr|
      tds = tr.css('td')
      href = tds[0].css('a')[0].attribute('href').to_s
      href =~ /\bln=([^&]+)\b/

      last_name = $1
      full_name = tds[0].css('a')[0].content.strip
      city = tds[1].content.strip
      award = tds[2].content.strip

      [ last_name, full_name, city, award ]
    end
  end

  def url_list
    return @url_list if @url_list

    text = doc.css('tfoot.pagination th:first')[0].content
    text.strip =~ /(\d+)-(\d+) \/ (\d+)/
    records_per_page = $2
    total_records = $3
    total_pages = (total_records.to_f / records_per_page.to_f).ceil

    @url_list = (1..total_pages).collect { |p| Url.sub('#{page}', p.to_s) }
  end
end

fetcher = Fetcher.new(OrderOfCanadaParser::Url.sub('#{page}', '1'), OrderOfCanadaParser)
fetcher.logger = Logger.new(STDERR)
CSV::Writer.generate(STDOUT) do |csv|
  fetcher.write_records_to_csv(csv, :flusher => STDOUT)
end
