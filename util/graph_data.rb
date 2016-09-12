require 'trollop'
require 'gnuplot'
require 'sequel'

@opts = Trollop::options do
  opt :date, "Snapshot Date", :type => :string
  opt :tickers, "Tickers to draw data for", :type => :string
  opt :list, "File with list of tickers to draw", :type => :string
  opt :after, "Days after snapshot", :type => :integer, :default => 63 
  opt :before, "Days before snapshot", :type => :integer, :default => 500
  opt :db, "Database to get data from", :type => :string, :default => 'finance'
  opt :password, "Password for database", :type => :string
  opt :user, "Username for database", :type => :string
  opt :directory, "Directory to save snapshots to", :type => :string
end

def pull_data(ticker, date)
  prices = DB[:historical]
  splits = DB[:splits]

  end_date = prices.where('date >= ? and ticker = ?', @opts[:date], ticker).limit(1).offset(@opts[:after] - 1).first
  start_date = prices.where('date <= ? and ticker = ?', @opts[:date], ticker).limit(1).offset(@opts[:before] - 1).reverse_order(:date).first
  return if start_date.nil? || end_date.nil?

  unsplit_prices = prices.where('ticker = ? and date >= ? and date <= ?', ticker, start_date[:date].to_s, end_date[:date].to_s).all 
  price_splits = splits.where('ticker = ? and date >= ? and date <= ?', ticker, start_date[:date].to_s, end_date[:date].to_s).all

  price_splits.each do |split|
    days_before = unsplit_prices.select { |p| p[:date] < split[:date] }
    split_ratio = split[:bef] / split[:after].to_f
    days_before.map! do |day|
      day[:open] *= split_ratio
      day[:high] *= split_ratio
      day[:close] *= split_ratio
      day[:low] *= split_ratio
    end
  end

  unsplit_prices
end

def draw_data(data, ticker, date)

  dates = data.map { |x| x[:date].to_s}
  closes = data.map { |x| x[:close] }
  opens = data.map { |x| x[:open] }
  highs = data.map { |x| x[:high] }
  lows = data.map { |x| x[:low] }

  minlow = lows.min.to_i * 0.95
  maxhi = highs.max.to_i * 1.05
  x_values = (1..dates.size).to_a

  Gnuplot.open do |gp|
    Gnuplot::Plot.new( gp ) do |plot|
    
      plot.title  "#{ticker} - #{date}"
      plot.ylabel "price"
      plot.xlabel "days"
      plot.xrange "[1:#{data.length}]"
      plot.yrange "[#{minlow}:#{maxhi}]"
      plot.terminal('png size 2048,1024')
      plot.output("#{@opts[:directory]}/#{ticker}-#{date}.png")
      plot.grid
  
      plot.data << Gnuplot::DataSet.new( [x_values, opens, lows, highs, closes] ) do |ds|
#         ds.with = "candlesticks"
         ds.with = "financebars lt 8"
         ds.notitle
      end

      plot.data << Gnuplot::DataSet.new() do |ds|
        ds.with = "lines"
      end
    end 
  end
end

DB = Sequel::mysql(@opts[:db], :host => 'localhost', :user => @opts[:user], :password => @opts[:password]) 

if(@opts[:tickers])
  tickers = @opts[:tickers].split(',') 
else
  tickers = File.read(@opts[:list]).split
end

tickers.each do |ticker|
  data = pull_data(ticker, @opts[:date])

  if data.nil? || data.empty?
    puts "NOT ENOUGH DATA"
  else
    draw_data(data, ticker, @opts[:date])
  end
end
