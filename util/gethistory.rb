#!/usr/bin/env ruby

require 'open-uri'
require 'trollop'
require 'sequel'

@opts = Trollop::options do
  opt :tickers, "Comma separated list of tickers to fetch", :type => :string
  opt :list, "Stock universe to fetch data for", :type => :string
  opt :start, "Starting date (MM-DD-YYYY)", :type => :string, :required => true
  opt :end, "Ending date (required for Google)", :type => :string
  opt :yahoo, "Use Yahoo as data source", :type => :boolean
  opt :google, "Use Google as data source", :type => :boolean, :default => false
  opt :exchange, "Exchange of given stock universe (required for Google)", :type => :string
  opt :database, "Database to write results to", :type => :string, :default => "finance"
  opt :password, "Password for database connection", :type => :string
  opt :user, "User for database connection", :type => :string
  opt :dump, "Dump data without writing to db", :type => :boolean
end

def fetch(url)
  begin
    raw = open(url).read
    raw.lines.to_a[1..-1]
  rescue => e
    puts "\nURL: #{url}\n#{e.message}"  
  end
end

def fetch_from_google(ticker, startdate, enddate)
    abort('No exchange specified') if @opts[:exchange].nil?
    url = "http://www.google.com/finance/historical?q=#{@opts[:exchange]}:#{ticker}&startdate=#{startdate}&enddate=#{enddate}&output=csv";
    fetch(url)
end

def fetch_from_yahoo(ticker, startdate, enddate)
    first = startdate.split('-')
    last = enddate.split('-')
    first.map!(&:to_i)
    last.map!(&:to_i)

    first[0] -= 1
    last[0] -= 1

    url = "http://ichart.finance.yahoo.com/table.csv?s=#{ticker}&a=#{first[0]}&b=#{first[1]}&c=#{first[2]}";
    url += "&g=d&d=#{last[0]}&e=#{last[1]}&f=#{last[2]}&ignore=.csv";
    fetch(url)
end

def connect_to_db
  condata = {}
  condata[:host] = 'localhost'
  condata[:user] = @opts[:user] if @opts[:user]
  condata[:password] = @opts[:password] if @opts[:password]
  db = Sequel::mysql(@opts[:database], condata) 
  db[:historical]
end

if(@opts[:tickers])
  tickers = @opts[:tickers].split(',') 
else
  tickers = File.read(@opts[:list]).split
end

enddate = (@opts[:end].nil? ? @opts[:start] : @opts[:end])
labels = [:ticker, :date, :open, :high, :low, :close, :volume] 
prices = connect_to_db

tickers.each do |ticker|
  puts "FETCH #{ticker}"

  if(@opts[:google])
    data = fetch_from_google(ticker, @opts[:start], enddate)  
  else
    data = fetch_from_yahoo(ticker, @opts[:start], enddate) 
  end

  if data.nil?
    puts "SKIPPING #{ticker}"
    next
  end

  data.each do |cur|
    values = cur.chomp.split(',')
    values[0] = Date.strptime(values.first, '%d-%b-%y').to_s if @opts[:google]
    values.unshift(ticker)

    begin
      if @opts[:dump]
        puts values.join("\t")
      else
        prices.insert(Hash[labels.zip(values)])
      end
    rescue => e
      puts e.message
    end
  end
end
