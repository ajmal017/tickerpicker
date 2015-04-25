#!/usr/bin/env ruby

require 'pry'

load 'codegen.rb'
require 'trollop'
require 'open3'
require 'date'
require 'json'

def dehash(key, raw)
   raw.gsub(/#{key}\s*:\s*\{(.+)\}/, key + ': [\1]')
end

def merge_opts(strat, target, opt)
  unless(strat.nil?)
    if(opt)
      strat[target] << opt
    end
  
    strat[target].map! {|x| x += ';' unless x[-1] == ';'} 
    strat[target] = strat[target].join(' ') 
  end
end

opts = Trollop::options do
  opt :start, "Starting date", :type => :string, :required => true
  opt :finish, "Ending date", :type => :string, :default => DateTime.now.strftime("%Y-%m-%d")
  opt :periods, "Backtest length in bars", :type => :string
  opt :tickers, "Comma separated list of tickers to run backtest on", :type => :string
  opt :list, "Stock universe to run backtest on", :type => :string
  opt :strategy, "Strategy file", :type => :string
  opt :lstop, "Long stop loss rule", :type => :string
  opt :lsize, "Long position sizing rule", :type => :string
  opt :letrig, "Long entry trigger file", :type => :string
  opt :lesig, "Long entry signal file", :type => :string
  opt :lxtrig, "Long exit trigger file", :type => :string
  opt :lxsig, "Long exit signal file", :type => :string
  opt :lfilter, "Long trade filter", :type => :string
  opt :lreject, "Long trade rejection filter", :type => :string
  opt :exename, "Name of the engine executable file", :type => :string, :default => "btest.bin"
  opt :engine, "Path for the backtest engine, if not current directory", :type => :string, :default => "../src/"
  opt :dump, "Dump resulting three address code", :type => :boolean
  opt :all, "Perform an all-trades backtest", :type => :boolean, :default => false
  opt :random, "Randomize candidate selection", :type => :boolean, :default => false
  opt :benchmark, "Benchmark ticker", :type => :string, :default => "^IXIC" 
  opt :exclude, "Comma separated list of tickers to skip", :type => :string
  opt :slippage, "Per-transaction slippage expression", :type => :string
end

Trollop::die "You must specify a list of stocks" unless opts[:list] || opts[:tickers]

rawlist = (opts[:list] ? File.read(opts[:list]) : opts[:tickers].split(','))
strategy = {}

if(opts[:strategy])
  raw = File.read(opts[:strategy])
  raw = dehash('filter', raw)
  raw = dehash('reject', raw)
  raw = dehash('stop', raw)
  raw = dehash('size', raw)
  strategy = eval("{#{raw}}")
end

merge_opts(strategy[:long], :stop, opts[:lstop])
merge_opts(strategy[:long], :size, opts[:lsize])
merge_opts(strategy[:long], :filter, opts[:lfilter])
merge_opts(strategy[:long], :reject, opts[:lreject])

if(opts[:dump])
  puts strategy
end
