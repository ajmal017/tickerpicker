#!/usr/bin/env ruby

require 'stock_quote'
require 'trollop'
require 'sequel'

@opts = Trollop::options do
  opt :tickers, "Comma separated list of tickers to fetch", :type => :string
  opt :list, "Stock universe to fetch data for", :type => :string
  opt :database, "Database to write results to", :type => :string, :default => "finance"
  opt :password, "Password for database connection", :type => :string
  opt :user, "User for database connection", :type => :string
  opt :dump, "Dump data without writing to db", :type => :boolean
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

labels = [:date, :open, :high, :low, :close, :volume]
prices = connect_to_db

tickers.each do |ticker|
  puts "FETCH #{ticker}"

  data = StockQuote::Stock.chart(ticker, '1m')

  if data.nil?
    puts "SKIPPING #{ticker}"
    next
  end

  data.chart.each do |current|
    bar = labels.map { |x| [x, current[x.to_s]] }
    bar = bar.to_h
    bar[:ticker] = ticker

    begin
      prices.insert(bar)
    rescue Sequel::UniqueConstraintViolation
      puts "Skipping duplicate bar #{ticker} on #{bar[:date]}"
    rescue Sequel::NotNullConstraintViolation
      puts "Skipping missing data for #{ticker} on #{bar[:date]}"
    end
  end
end
