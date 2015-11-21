#!/usr/bin/env ruby

load 'codegen.rb'
require 'trollop'
require 'date'
require 'json'

def dehash(key, raw)
   raw.gsub(/#{key}\s*:\s*\{(.+)\}/, key + ': [\1]')
end

def add_to_hash(value, base, *keys)
  unless(value.nil?)
    current = base
    keys[0..-2].each do |k|
      unless(current[k])
        current[k] = {}
      end
 
      current = current[k]
    end

    k = keys[-1]
    unless(current[k])
      current[k] = ""
    end

    current[k] += value.chomp(';') + ';'
  end
end

def process_expression(exp)
  exp = exp.join(' ') if exp.is_a? Array
  p = CodeGenerator::Parser.new(exp)
  p.parse_exp
  p.table.symboltable 
end

def process_screen(s)
  p = CodeGenerator::Parser.new(s)
  p.parse_rules
  {rules: p.table.rules, symbols: p.table.symboltable} 
end

def print_results(buf)
  results = JSON.parse(buf)
  puts ''

  results['trades'].each do |trade|
    print trade.join("\t")
    print "\t[OPEN]" if trade.size == 4
    puts
  end

  puts ''
  puts 'Equity: ' + results['stats']['equity'].to_s
  puts 'Dividends: ' + results['stats']['dividends'].to_s
  puts 'Return: ' + results['stats']['return'].to_s

  if(results['stats']['benchmark'])
    puts 'Benchmark: ' + results['stats']['benchmark'].to_s
  end

  puts 'Winners: ' + results['stats']['winners'].to_s
  puts 'Losers: ' + results['stats']['losers'].to_s
  puts 'Win %: ' + results['stats']['winpercent'].to_s
  puts 'Lose %: ' + results['stats']['losepercent'].to_s
  puts 'Avg Win: ' + results['stats']['avgwin'].to_s 
  puts 'Avg Loss: ' + results['stats']['avgloss'].to_s
  puts 'Max Drawdown: ' + results['stats']['drawdown'].to_s
  puts 'Profit / Drawdown: ' + '%.2f' % (results['stats']['return'] / results['stats']['drawdown']).to_s
  puts 'Expectancy: ' + results['stats']['expect'].to_s
  puts ''
end

opts = Trollop::options do
  opt :start, "Starting date", :type => :string, :required => true
  opt :finish, "Ending date", :type => :string, :default => DateTime.now.strftime("%Y-%m-%d")
  opt :periods, "Backtest length in bars", :type => :string
  opt :tickers, "Comma separated list of tickers to run backtest on", :type => :string
  opt :list, "Stock universe to run backtest on", :type => :string
  opt :strategy, "Strategy file", :type => :string
  opt :lstop, "Long stop loss rule", :type => :string
  opt :ltrail, "Long trailing stop loss rule", :type => :string
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
  opt :benchmark, "Benchmark ticker", :type => :string
  opt :exclude, "Comma separated list of tickers to skip", :type => :string
  opt :multi, "Allow multiple positions for the same ticker", :type => :boolean
  opt :slippage, "Per-transaction slippage expression", :type => :string
  opt :raw, "Dump raw trade results", :type => :boolean
  opt :dumpcmd, "Dump engine command line", :type => :boolean
  opt :asort, "Ascending sort expression for screener results", :type => :string
  opt :dsort, "Descending sort expression for screener results", :type => :string
end

Trollop::die "You must specify a list of stocks" unless opts[:list] || opts[:tickers]

rawlist = (opts[:list] ? File.read(opts[:list]) : opts[:tickers].split(','))
strategy = {}

if(opts[:strategy])
  raw = File.read(opts[:strategy])
  raw = dehash('filter', raw)
  raw = dehash('reject', raw)
  raw = dehash('trail', raw)
  raw = dehash('stop', raw)
  raw = dehash('size', raw)
  strategy = eval("{#{raw}}")
end

add_to_hash(opts[:lesig], strategy, :long, :enter, :signal)
add_to_hash(opts[:letrig], strategy, :long, :enter, :trigger)
add_to_hash(opts[:lxsig], strategy, :long, :exit, :signal)
add_to_hash(opts[:lxtrig], strategy, :long, :exit, :trigger)

add_to_hash(opts[:lstop], strategy, :long, :stop)
add_to_hash(opts[:lsize], strategy, :long, :size)
add_to_hash(opts[:ltrail], strategy, :long, :trail)
add_to_hash(opts[:lfilter], strategy, :long, :filter)
add_to_hash(opts[:lreject], strategy, :long, :reject)

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
  processed[:long][:trail] = process_expression(raw[:trail]) if raw[:trail]
  processed[:long][:filter] = process_expression(raw[:filter]) if raw[:filter]
  processed[:long][:reject] = process_expression(raw[:reject]) if raw[:reject]
end

if(opts[:asort])
   p = CodeGenerator::Parser.new(opts[:asort])
   p.parse_exp
   processed[:long][:enter][:signal][:asort] = p.table.symboltable 
end

if(opts[:dsort])
   p = CodeGenerator::Parser.new(opts[:dsort])
   p.parse_exp
   processed[:long][:enter][:signal][:dsort] = p.table.symboltable 
end

processed[:config] = {}
processed[:config][:multipos] = opts[:multi]

if(opts[:slippage])
  processed[:config][:slippage] = process_expression(opts[:slippage])
else
  processed[:config][:slippage] = []
end

if(opts[:benchmark]) 
  processed[:config][:benchmark] = opts[:benchmark]
end

if(opts[:dump])
  puts processed.to_json
end

Dir.chdir(opts[:engine])
cmdline = "./#{opts[:exename]} #{opts[:start]} #{opts[:finish]} "
cmdline += (opts[:list].nil? ? "-l #{opts[:tickers]}" : "-f #{opts[:list]}")

if (opts[:dumpcmd])
  puts cmdline
end

buf = `echo '#{processed.to_json}' | #{cmdline}`

if(opts[:raw])
  puts buf
else
  print_results(buf)
end
