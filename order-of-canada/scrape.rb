#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'httparty'
require 'nokogiri'

require 'csv'
require 'logger'
require 'uri'

class HTTP
  include HTTParty
end

class Parser
  attr_reader(:html)

  def initialize(html)
    @html = html
  end

  def total_pages
    raise NotImplementedError.new
  end

  def records
    raise NotImplementedError.new
  end

  protected

  def doc
    @doc ||= Nokogiri::HTML(html)
  end
end

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

class Fetcher
  attr_accessor(:logger)
  attr_reader(:url_template, :parser_class)

  def initialize(url_template, parser_class)
    @url_template = url_template
    @parser_class = parser_class
  end

  def count
    @count ||= calculate_count
  end

  def pages
    @pages ||= calculate_pages
  end

  def records
    @records ||= calculate_records
  end

  def write_records_to_csv(csv, options = {})
    start_page = options[:start_page] || 1
    (start_page..pages).each do |page|
      parsed_page(page).records.each do |record|
        puts "Writing #{record.inspect}..."
        csv << [ record[:last_name], record[:full_name], record[:city], record[:award] ]
      end
      options[:flusher].flush if options[:flusher]
    end
  end

  protected

  def html_page(n)
    @html_pages ||= {}
    @html_pages[n] ||= calculate_html_page(n)
  end

  def parsed_page(n)
    @parsed_pages ||= {}
    @parsed_pages[n] ||= parse_page(html_page(n))
  end

  def parse_page(html)
    parser_class.new(html)
  end

  def calculate_html_page(n)
    url = @url_template.gsub('#{page}', n.to_s)
    log("Fetching #{url}...")
    HTTP.get(url).body
  end

  def calculate_pages
    parsed_page(1).total_pages
  end

  def calculate_records
    ret = []
    (1..pages).each do |page|
      records = parsed_page(page).records
      log("Records: #{records.inspect}")
      ret.concat(records)
    end
    ret
  end

  def log(msg)
    logger.info(msg) if logger
  end
end

url = 'http://www.gg.ca/honours.aspx?q=&t=12&p=&c=&pg=#{page}&types=12'
fetcher = Fetcher.new(url, OrderOfCanadaParser)
fetcher.logger = Logger.new(STDOUT)
File.open('./order-of-canada.csv', 'a') do |f|
  CSV::Writer.generate(f) do |csv|
    fetcher.write_records_to_csv(csv, :flusher => f, :start_page => 1)
  end
end
