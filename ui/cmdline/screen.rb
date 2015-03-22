#!/usr/bin/env ruby

load 'codegen.rb'
require 'trollop'
require 'open3'
require 'date'
require 'json'

opts = Trollop::options do
  opt :screen, "Screening criteria file", :type => :string
  opt :list, "Stock universe to run screen against", :type => :string
  opt :tickers, "Comma separated list of tickers to screen", :type => :string
  opt :criteria, "Semicolon separated list of screening rules", :type => :string
  opt :date, "Date to run screen on", :type => :string, :default => DateTime.now.strftime("%Y-%m-%d")
  opt :exename, "Name of the engine executable file", :type => :string, :default => "a.out"
  opt :engine, "Path for the screening engine, if not current directory", :type => :string, :default => "../../src/"
  opt :dump, "Dump resulting three address code", :type => :boolean
end

Trollop::die :screen, "You must specify screening criteria" unless opts[:screen] || opts[:criteria]
Trollop::die "You must specify a list of stocks to screen" unless opts[:list] || opts[:tickers]

rawlist = (opts[:list] ? File.read(opts[:list]) : opts[:tickers].split(','))
rawscreen = (opts[:screen] ? File.read(opts[:screen]) : opts[:criteria])
p = CodeGenerator::Parser.new(rawscreen)

p.parse_rules
screen = {rules: p.table.rules, symbols: p.table.symboltable}
puts screen if opts[:dump]

Dir.chdir(opts[:engine])
cmdline = "./#{opts[:exename]} #{opts[:date]} "
cmdline += (opts[:list].nil? ? "-l #{opts[:tickers]}" : "-f #{opts[:list]}")

stdin, stdout, stderr, wait_thr = Open3.popen3(cmdline)
stdin.puts({screen: screen}.to_json + "\n")
stdin.close

stdout.each_line {|line| puts line }
