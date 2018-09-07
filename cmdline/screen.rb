#!/usr/bin/env ruby

load 'codegen.rb'
require 'optimist'
require 'date'
require 'json'

opts = Optimist::options do
  opt :screen, "Screening criteria file", :type => :string, :multi => true
  opt :list, "Stock universe to run screen against", :type => :string
  opt :tickers, "Comma separated list of tickers to screen", :type => :string
  opt :criteria, "Semicolon separated list of screening rules", :type => :string, :multi => true
  opt :date, "Date to run screen on", :type => :string, :default => DateTime.now.strftime("%Y-%m-%d")
  opt :exename, "Name of the engine executable file", :type => :string, :default => "screen.bin"
  opt :engine, "Path for the screening engine, if not current directory", :type => :string, :default => "../src/"
  opt :dump, "Dump resulting three address code", :type => :boolean
  opt :asort, "Ascending sorting rule for results", :type => :string
  opt :dsort, "Descending sorting rule for results", :type => :string
  opt :exp, "Expression for calculated column", :type => :string
end

Trollop::die "You must specify either ascending or descending sort" if(opts[:asort] && opts[:dsort])
Trollop::die :screen, "You must specify screening criteria" unless opts[:screen] || opts[:criteria]
Trollop::die "You must specify a list of stocks to screen" unless opts[:list] || opts[:tickers]

rawlist = (opts[:list] ? File.read(opts[:list]) : opts[:tickers].split(','))
rawscreen = ''

if(opts[:criteria])
  rawscreen += opts[:criteria].join(' ')
end

if(opts[:screen]) 
  opts[:screen].each do |s|
    rawscreen += File.read(s) + ' '
  end
end

p = CodeGenerator::Parser.new(rawscreen)

p.parse_rules
screen = {:rules => p.table.rules, :symbols => p.table.symboltable}

if(opts[:asort])
   p = CodeGenerator::Parser.new(opts[:asort])
   p.parse_exp
   screen[:asort] = p.table.symboltable 
end

if(opts[:dsort])
   p = CodeGenerator::Parser.new(opts[:dsort])
   p.parse_exp
   screen[:dsort] = p.table.symboltable 
end

if(opts[:exp])
  p = CodeGenerator::Parser.new(opts[:exp])
  p.parse_exp
  screen[:calc] = p.table.symboltable
end

puts screen if opts[:dump]

Dir.chdir(opts[:engine])
cmdline = "./#{opts[:exename]} #{opts[:date]} "
cmdline += (opts[:list].nil? ? "-l #{opts[:tickers]}" : "-f #{opts[:list]}")
puts `echo '#{{:screen => screen}.to_json}' | #{cmdline}`
