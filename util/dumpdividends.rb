#!/usr/bin/env ruby

require 'optimist'
require 'sequel'

@opts = Optimist::options do
  opt :tickers, "Comma separated list of tickers to dump", :type => :string
  opt :list, "Stock universe to dump data for", :type => :string
  opt :path, "Directory to store bin files in", :type => :string
end

def pack_date(d)
  (d.year * 10_000) + (d.month * 100) + d.day
end

DB = Sequel::mysql('finance', :host => 'localhost', :user => 'perldb') 
dividends = DB[:dividends]

if(@opts[:tickers])
  tickers = @opts[:tickers].split(',') 
else
  tickers = File.read(@opts[:list]).split
end

tickers.each do |ticker|
  rows = dividends.where(:ticker => ticker).all.reverse

  if(rows.count > 0)
    puts "DUMPING #{ticker} - #{rows.count}"
    path = (@opts[:path].nil? ? '' : @opts[:path] + '/') 
    data = File.open("#{path}#{ticker.gsub(/\//, '-')}.div", "w")

    rows.each do |dividend|
      pdate = pack_date(dividend[:date])
      row = [pdate, dividend[:divamt] * 10000]
      raw = row.pack("NN")
      data.write(raw)
    end
  end
end
