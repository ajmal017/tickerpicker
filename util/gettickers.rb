#!/usr/bin/env ruby

require 'open-uri'
require 'open_uri_redirections'
require 'csv'

urls = {
  nasdaq: "http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nasdaq&render=download",
  nyse: "http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=nyse&render=download",
  amex: "http://www.nasdaq.com/screening/companies-by-name.aspx?letter=0&exchange=amex&render=download",
}

urls.each do |k, v|
  raw = open(v, :allow_redirections => :safe).read
  csv = CSV.parse(raw)

  File.open(k.to_s + '.txt', 'w') do |f|
    csv[1..-1].each do |x|
      f.write(x.first + "\n")
    end
  end
end
