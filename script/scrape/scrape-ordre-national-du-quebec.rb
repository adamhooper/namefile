#!/usr/bin/env ruby

require 'scrape'

require 'csv'
require 'logger'

class OrdreNationalDuQuebecParser < Parser
  Url = 'http://www.ordre-national.gouv.qc.ca/membres/resultats-en.asp?action=recherche&page=#{page}&nom=+'
  MemberUrl = 'http://www.ordre-national.gouv.qc.ca/membres/#{part}'
  LeadingWhitespaceRegex = /^(?:\s|\302\240)*/
  TrailingWhitespaceRegex = /(?:\s|\302\240)*$/

  def initialize(html)
    super(html)
  end

  def records
    @records ||= doc.css('table#resultats tbody tr').collect do |tr|
      tds = tr.css('td')
      href = tds[0].css('a')[0].attribute('href').to_s

      last_name, first_name = tds[0].text.to_s.split(/,/).collect { |s| s.sub(LeadingWhitespaceRegex, '').sub(TrailingWhitespaceRegex, '') }

      full_name = "#{first_name} #{last_name}"
      title = case tds[1].text
        when 'C.Q.' then 'Knight'
        when 'O.Q.' then 'Officer'
        when 'G.O.Q.' then 'Grand Officer'
        else '???'
      end
      year = tds[2].text.to_i
      region = tds[3].text
      deceased = (tds[4].css('img').length > 0)
      url = MemberUrl.sub('#{part}', href)

      [ last_name, full_name, title, year, region, deceased, url ]
    end
  end

  def url_list
    return @url_list if @url_list

    total_pages = doc.css('ul.pages li').last.text.to_i

    @url_list = (1..total_pages).collect { |p| Url.sub('#{page}', p.to_s) }
  end
end

fetcher = Fetcher.new(OrdreNationalDuQuebecParser::Url.sub('#{page}', '1'), OrdreNationalDuQuebecParser)
fetcher.logger = Logger.new(STDERR)
CSV::Writer.generate(STDOUT) do |csv|
  fetcher.write_records_to_csv(csv, :flusher => STDOUT)
end
