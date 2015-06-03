#!/usr/bin/env ruby

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

def merge_entry(entry, key, opt)
  unless(entry[key].nil?)
    rules = entry[key]
    entry[key] += ';' unless rules[-1] == ';'
    entry[key] += opt unless opt.nil?
  end
end

def process_expression(exp)
 p = CodeGenerator::Parser.new(exp)
 p.parse_exp
 p.table.symboltable 
end

def process_screen(s)
 p = CodeGenerator::Parser.new(s)
 p.parse_rules
 {rules: p.table.rules, symbols: p.table.symboltable} 
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
  opt :multi, "Allow multiple positions for the same ticker", :type => :boolean
  opt :slippage, "Per-transaction slippage expression", :type => :string
  opt :raw, "Dump raw trade results", :type => :boolean
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

merge_entry(strategy[:long][:enter], :trigger, opts[:letrig])
merge_entry(strategy[:long][:enter], :signal, opts[:lesig])
merge_entry(strategy[:long][:exit], :trigger, opts[:lxtrig])
merge_entry(strategy[:long][:exit], :signal, opts[:lxsig])

processed = {}

if(strategy[:long])
  processed[:long] = {}
  raw = strategy[:long]

  if(raw[:enter])
    processed[:long][:enter] = {}
    processed[:long][:enter][:signal] = process_screen(raw[:enter][:signal]) if raw[:enter][:signal]
    processed[:long][:enter][:trigger] = process_screen(raw[:enter][:trigger]) if raw[:enter][:trigger]
  end

  if(raw[:exit])
    processed[:long][:exit] = {}
    processed[:long][:exit][:signal] = process_screen(raw[:exit][:signal]) if raw[:exit][:signal]
    processed[:long][:exit][:trigger] = process_screen(raw[:exit][:trigger]) if raw[:exit][:trigger]
  end

  processed[:long][:stop] = process_expression(raw[:stop]) if raw[:stop]
  processed[:long][:size] = process_expression(raw[:size]) if raw[:size]
  processed[:long][:filter] = process_expression(raw[:filter]) if raw[:filter]
  processed[:long][:reject] = process_expression(raw[:reject]) if raw[:reject]
end

processed[:config] = {}
processed[:config][:multipos] = opts[:multi]
processed[:config][:slippage] = opts[:slippage]


if(opts[:dump])
  puts processed.to_json
end

Dir.chdir(opts[:engine])
cmdline = "./#{opts[:exename]} #{opts[:start]} #{opts[:finish]} "
cmdline += (opts[:list].nil? ? "-l #{opts[:tickers]}" : "-f #{opts[:list]}")

stdin, stdout, stderr, wait_thr = Open3.popen3(cmdline)
stdin.puts(processed.to_json + "\n")
stdin.close

sys_stat = wait_thr.value.to_i
if(sys_stat != 0)
  abort("RUNTIME ERROR: #{sys_stat}")
end

buf = ''
stdout.each_line {|line| buf += line }

if(opts[:raw])
  puts buf
else
  results = JSON.parse(buf)
  results['trades'].each do |trade|
    print trade.join("\t")
    print "\t[OPEN]" if trade.size == 3
    puts
  end
end
