#!/usr/bin/env ruby

require 'optimist'
require 'sequel'
require 'pry'

@opts = Optimist::options do
  opt :tickers, "Comma separated list of tickers to audit", :type => :string
  opt :list, "Stock universe to audit", :type => :string
  opt :database, "Database to get data from", :type => :string, :default => "finance"
  opt :password, "Password for database connection", :type => :string
  opt :user, "User for database connection", :type => :string
end

def connect_to_db
  condata = {}
  condata[:host] = 'localhost'
  condata[:user] = @opts[:user] if @opts[:user]
  condata[:password] = @opts[:password] if @opts[:password]
  Sequel::mysql(@opts[:database], condata) 
end

def check_splits(ticker)
  rawsplits = @db[:splits].where(ticker: ticker).all
  return if rawsplits.size.zero?

  rawsplits.each do |split|
    
    edate = split[:date].to_s
    data = @db[:historical].where(ticker: ticker).where{date <= edate}.reverse_order(:date).limit(2).all

    if data.size.zero?
      puts "#{ticker}: Missing price data for split at #{edate}"
      next
    end

    after_open = data.last[:open]
    before_open = data[-2][:open]

    after_open *= (split[:bef] / split[:after].to_f)
    percent_diff = ((after_open - before_open) / before_open) * 100

binding.pry
    if(percent_diff.abs > 10)
      puts "#{ticker}: Possible unadjusted split at #{split[:date].to_s}"
    end
  end
end

if(@opts[:tickers])
  tickers = @opts[:tickers].split(',') 
else
  tickers = File.read(@opts[:list]).split
end

@db = connect_to_db

tickers.each do |cur|
  check_splits(cur)
end
