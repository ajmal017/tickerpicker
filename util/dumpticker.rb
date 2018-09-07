#!/usr/bin/env ruby

require 'optimist'
require 'sequel'

@opts = Optimist::options do
  opt :tickers, "Comma separated list of tickers to dump", :type => :string
  opt :list, "Stock universe to dump data for", :type => :string
  opt :path, "Directory to store bin files in", :type => :string
  opt :password, "Password for database login", :type => :string
  opt :user, "User for database login", :type => :string
  opt :db, "Database to pull data from", :type => :string, :default => 'finance'
  opt :debug, "Show debug information", :type => :boolean
end

def pack_date(d)
  (d.year * 10_000) + (d.month * 100) + d.day
end

def write_index(rows, out)
  index = [] 
  year = 0
  
  rows.each_with_index do |row, i|
    unless(year == row[:date].year)
      year = row[:date].year
      index.unshift(i)
      index.unshift(year)
    end
  end
  
  index.unshift(index.length / 2)
  out.write(index.pack("N*"))

  if(@opts[:debug])
    puts "INDEX:"
    puts index
  end
end

def write_splits(out, ticker)
  splitdata = @splits.where(:ticker => ticker).all
  out.write([splitdata.count].pack("N"))
  
  splitdata.each do |split|
   data = [pack_date(split[:date]), split[:bef], split[:after]] 
   out.write(data.pack("NNN"))
  end

  if(@opts[:debug])
    puts "SPLITS"
    puts splitdata
  end
end

def write_price_data(rows, out)

  out.write([rows.count].pack("N"))

  rows.each do |row|
    pdate = pack_date(row[:date])
    data = [row[:open], row[:high], row[:low], row[:close]]
    data.map! {|x| (x * 100).to_i}
    data.push(row[:volume])
    data.unshift(pdate)
  
    raw = data.pack("NNNNNN")
    out.write(raw)
  end
end

DB = Sequel::mysql(@opts[:db], :host => 'localhost', :user => @opts[:user], :password => @opts[:password]) 
prices = DB[:historical]
@splits = DB[:splits]

if(@opts[:tickers])
  tickers = @opts[:tickers].split(',') 
else
  tickers = File.read(@opts[:list]).split
end

tickers.each do |ticker|
  puts "DUMPING #{ticker}"
  rows = prices.where(:ticker => ticker).all.reverse

  if(rows.count > 0)
    path = (@opts[:path].nil? ? '' : @opts[:path] + '/') 
    data = File.open("#{path}#{ticker.gsub(/\//, '-')}.ptab", "w")
    write_index(rows, data)
    write_splits(data, ticker)
    write_price_data(rows, data)
    data.close
  end
end
