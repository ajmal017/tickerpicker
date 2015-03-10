#!/usr/bin/env ruby

require 'trollop'
load 'parser.rb'
require 'date'

opts = Trollop::options do
  opt :screen, "Screening criteria file", :type => :string
  opt :list, "Stock universe to run screen against", :type => :string
  opt :tickers, "Comma separated list of tickers to screen", :type => :string
  opt :criteria, "Semicolon separated list of screening rules", :type => :string
  opt :engine, "Path for the screening engine, if not current directory", :type => :string
  opt :date, "Date to run screen on", :type => :string, :default => DateTime.now.strftime("%Y-%m-%d")
  opt :dump, "Dump resulting three address code", :type => :boolean
end

Trollop::die :screen, "You must specify screening criteria" unless opts[:screen] || opts[:criteria]
Trollop::die "You must specify a list of stocks to screen" unless opts[:list] || opts[:tickers]

rawlist = (opts[:list] ? File.read(opts[:list]) : opts[:tickers].split(','))
rawscreen = (opts[:screen] ? File.read(opts[:screen]) : opts[:criteria])

p = Parser.new(rawscreen)
p.parse_rules
screen = {rules: p.table.rules, symbols: p.table.symboltable}
puts screen if opts[:dump]
