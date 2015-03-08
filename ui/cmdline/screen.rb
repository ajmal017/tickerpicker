#!/usr/bin/env ruby

require 'trollop'
load 'parser.rb'
require 'date'

opts = Trollop::options do
  opt :screen, "Screening criteria file", :type => :string
  opt :list, "Stock universe to run screen against", :type => :string
  opt :date, "Date to run screen on", :type => :string, :default => DateTime.now.strftime("%Y-%m-%d")
  opt :tickers, "Comma separated list of tickers to screen", :type => :string
end

Trollop::die :screen, "You must specify screening criteria" unless opts[:screen]
Trollop::die "You must specify a list of stocks to screen" unless opts[:list] || opts[:tickers]

rawlist = (opts[:list] ? File.read(opts[:list]) : opts[:tickers].split(','))
rawscreen = File.read(opts[:screen])

p = Parser.new(rawscreen)
p.parse_rules
