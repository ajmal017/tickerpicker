#!/usr/bin/env ruby

require 'open-uri'
require 'trollop'
require 'sequel'
require 'csv'

@opts = Trollop::options do
  opt :tickers, "Comma separated list of tickers to fetch", :type => :string
  opt :list, "Stock universe to fetch data for", :type => :string
  opt :start, "Starting date (MM-DD-YYYY)", :type => :string, :required => true
  #opt :end, "Ending date (required for Google)", :type => :string
  opt :database, "Database to write results to", :type => :string, :default => "finance"
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

def insert(table, row)
  begin
    @db[table].insert(row)
  rescue => e
    puts e.message
  end
end

def process_split(row, ticker)
  split_date = Date.parse(row[1].strip)
  split_nums = row.last.split(':')
  new_row = {:date => split_date.to_s, :ticker => ticker, :bef => split_nums.last, :after => split_nums.first}
  insert(:splits, new_row)
end

def process_dividend(row, ticker)
  div_date = Date.parse(row[1].strip)
  div_amt = row.last
  new_row = {:date => div_date.to_s, :ticker => ticker, :divamt => div_amt}
  insert(:dividends, new_row)
end

if @opts[:tickers]
  list = @opts[:tickers].split(',')
else
  list = File.read(@opts[:list]).split
end

sdate = Date.strptime(@opts[:start], '%m-%d-%Y')
smonth, sday, syear = sdate.month, sdate.day, sdate.year
@db = connect_to_db

list.each do |cur|
  #http://ichart.finance.yahoo.com/x?s=IBM&a=00&b=2&c=1962&d=04&e=25&f=2011&g=v&y=0&z=30000
  url = "http://ichart.finance.yahoo.com/x?s=#{cur}&a=#{smonth - 1}&b=#{sday}&c=#{syear}&d=#{Time.now.month - 1}&e=#{Time.now.day}&f=#{Time.now.year}&g=v&y=0&z=30000"

  begin
    raw = open(url).read
  rescue => e
    puts "ON #{cur}: #{e.message}"
    next
  end

  csvdata = CSV.parse(raw)

  csvdata.each do |row|
    process_split(row, cur) if row.first == 'SPLIT'
    process_dividend(row, cur) if row.first == 'DIVIDEND'
  end 
end
