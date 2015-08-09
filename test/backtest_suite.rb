require 'json'

HOMEDIR = Dir.pwd

def run_test(tickers, start, done, sys)
  Dir.chdir("../cmdline")
  cmdline = "./backtest.rb --start #{start} --finish #{done} --tickers #{tickers.join(',')} --raw "

  if(sys[:longsig])
    cmdline += " --lesig '#{sys[:longsig]}'"
  end

  if(sys[:longxsig])
    cmdline += " --lxsig '#{sys[:longxsig]}'"
  end

  if(sys[:longstop])
    cmdline += " --lstop '#{sys[:longstop]}'"
  end

  output = `#{cmdline}`
  Dir.chdir(HOMEDIR)
  JSON.parse(output)
end

RSpec.describe "Long trades" do

  describe "Entry and exit signals" do

    it "should open a position the day after a signal" do
      results = run_test(%w(AAPL), '2015-02-20', '2015-03-20', {:longsig => "H = 133", :longxsig => "H = 0", :longstop => "0" })
      expect(results['trades']).to match_array([["2015-02-24", "1", "132.94"]])
  
      results = run_test(%w(AAPL), '2015-02-20', '2015-03-20', {:longsig => "L = 122.11", :longxsig => "H = 0", :longstop => "0" })
      expect(results['trades']).to match_array([["2015-03-12", "1", "122.31"]])
  
      results = run_test(%w(AAPL), '2015-02-20', '2015-03-20', {:longsig => "C = 127.04", :longxsig => "H = 0", :longstop => "0" })
      expect(results['trades']).to match_array([["2015-03-18", "1", "127"]])
  
      results = run_test(%w(AAPL), '2015-02-20', '2015-03-20', {:longsig => "O = 127", :longxsig => "H = 0", :longstop => "0" })
      expect(results['trades']).to match_array([["2015-03-19", "1", "128.75"]])

      results = run_test(%w(AAPL), '2015-02-20', '2015-03-20', {:longsig => "V = 48_145_700", :longxsig => "H = 0", :longstop => "0" })
      expect(results['trades']).to match_array([["2015-03-13", "1", "124.4"]])
    end
  
    it "should close a position the day after a signal" do
      results = run_test(%w(AAPL), '2015-02-20', '2015-03-28', {:longsig => "H = 133", :longxsig => "H = 129.25", :longstop => "0" })
      expect(results['trades']).to match_array([["2015-02-24", "1", "132.94", "2015-03-20", "128.25", "-3.53"]])
  
      results = run_test(%w(AAPL), '2015-02-20', '2015-03-28', {:longsig => "L = 122.11", :longxsig => "H = 129.25", :longstop => "0" })
      expect(results['trades']).to match_array([["2015-03-12", "1", "122.31", "2015-03-20", "128.25", "4.85"]])
  
      results = run_test(%w(AAPL), '2015-02-20', '2015-03-28', {:longsig => "C = 127.04", :longxsig => "H = 129.25", :longstop => "0" })
      expect(results['trades']).to match_array([["2015-03-18", "1", "127", "2015-03-20", "128.25", "0.98"]])
  
      results = run_test(%w(AAPL), '2015-01-20', '2015-03-28', {:longsig => "O = 120.17", :longxsig => "H = 129.37", :longstop => "0" })
      expect(results['trades']).to match_array([["2015-02-11", "1", "122.77", "2015-03-09", "127.96", "4.22"]])

      results = run_test(%w(AAPL), '2015-01-20', '2015-03-28', {:longsig => "V = 48_145_700", :longxsig => "C = 127.04", :longstop => "0" })
      expect(results['trades']).to match_array([["2015-03-13", "1", "124.4", "2015-03-18", "127", "2.09"]])
    end

    it "should defer zero volume days when selling" do
      results = run_test(%w(XOM), '2010-08-01', '2010-09-28', {:longsig => "O = 58.97", :longxsig => "O = 61.20", :longstop => "0" })
      expect(results['trades']).to match_array([["2010-08-24", "1", "58.96", "2010-09-07", "60.89", "3.27"]])

      results = run_test(%w(XOM), '2010-06-01', '2010-07-28', {:longsig => "H = 64.50", :longxsig => "L = 55.94", :longstop => "0" })
      expect(results['trades']).to match_array([["2010-06-22", "1", "63.13", "2010-07-06", "57.17", "-9.45"]])

      results = run_test(%w(XOM), '2010-05-01', '2010-06-20', {:longsig => "L = 58.46", :longxsig => "C = 60.46", :longstop => "0" })
      expect(results['trades']).to match_array([["2010-05-07", "1", "64.5", "2010-06-01", "60.38", "-6.39"]])

      results = run_test(%w(XOM), '2010-03-01', '2010-05-01', {:longsig => "H = 67.89", :longxsig => "C = 67.61", :longstop => "0" })
      expect(results['trades']).to match_array([["2010-03-22", "1", "66.48", "2010-04-05", "67.84", "2.04"]])
    end

    it "should skip zero volume days when buying" do
      results = run_test(%w(XOM), '2010-08-01', '2010-09-28', {:longsig => "O = 61.20", :longxsig => "O = 0", :longstop => "0" })
      expect(results['trades']).to match_array([["2010-09-07", "1", "60.89"]])

      results = run_test(%w(XOM), '2010-05-01', '2010-06-20', {:longsig => "O = 61.21", :longxsig => "C = 0", :longstop => "0" })
      expect(results['trades']).to match_array([["2010-06-01", "1", "60.38"]])

      results = run_test(%w(XOM), '2010-03-01', '2010-05-01', {:longsig => "O = 67.27", :longxsig => "C = 0", :longstop => "0" })
      expect(results['trades']).to match_array([["2010-04-05", "1", "67.84"]])
    end

    it "should not sell if the date becomes desynchronized" do
      results = run_test(%w(AAPL), '2014-11-10', '2014-12-01', {:longsig => "O = 114.91", :longxsig => "C = 119", :longstop => "0" })
      expect(results['trades']).to match_array([["2014-11-21", "1", "117.51", "2014-11-28", "119.27", "1.49"]])

      results = run_test(%w(AAPL), '2013-11-10', '2013-12-01', {:longsig => "O = 518", :longxsig => "H = 546", :longstop => "0" })
      expect(results['trades']).to match_array([["2013-11-14", "1", "522.8", "2013-11-29", "549.48", "5.1"]])

      results = run_test(%w(AAPL), '2012-11-10', '2012-12-01', {:longsig => "O = 545.5", :longxsig => "O = 564.25", :longstop => "0" })
      expect(results['trades']).to match_array([["2012-11-15", "1", "537.53", "2012-11-23", "567.16", "5.51"]])

      results = run_test(%w(AAPL), '2014-05-10', '2014-06-10', {:longsig => "O = 592", :longxsig => "O = 607.25", :longstop => "0" })
      expect(results['trades']).to match_array([["2014-05-14", "1", "592.42", "2014-05-27", "615.88", "3.96"]])

      results = run_test(%w(AAPL), '2009-05-10', '2009-06-10', {:longsig => "O = 123.21", :longxsig => "O = 124.05", :longstop => "0" })
      expect(results['trades']).to match_array([["2009-05-14", "1", "119.78", "2009-05-26", "124.76", "4.15"]])
    end

    it "should not buy if the date becomes desynchronized" do
      results = run_test(%w(AAPL), '2014-11-10', '2014-12-15', {:longsig => "O = 117.94", :longxsig => "C = 110.19", :longstop => "0" })
      expect(results['trades']).to match_array([["2014-11-28", "1", "119.27"]])

      results = run_test(%w(AAPL), '2013-11-10', '2013-12-10', {:longsig => "H = 546", :longxsig => "O = 565.5", :longstop => "0" })
      expect(results['trades']).to match_array([["2013-11-29", "1", "549.48", "2013-12-05", "572.65", "4.21"]])

      results = run_test(%w(AAPL), '2012-11-10', '2012-12-10', {:longsig => "O = 564.25", :longxsig => "O = 590.22", :longstop => "0" })
      expect(results['trades']).to match_array([["2012-11-23", "1", "567.16", "2012-11-30", "586.79", "3.46"]])

      results = run_test(%w(AAPL), '2014-05-10', '2014-06-10', {:longsig => "O = 607.25", :longxsig => "O = 633.96", :longstop => "0" })
      expect(results['trades']).to match_array([["2014-05-27", "1", "615.88", "2014-06-03", "628.46", "2.04"]])

      results = run_test(%w(AAPL), '2009-05-10', '2009-06-10', {:longsig => "O = 124.05", :longxsig => "O = 140", :longstop => "0" })
      expect(results['trades']).to match_array([["2009-05-26", "1", "124.76", "2009-06-04", "140.13", "12.31"]])
    end

    it "should not buy on static holidays" do
      results = run_test(%w(XOM), '2010-06-01', '2010-07-28', {:longsig => "O = 56.85", :longxsig => "C = 0", :longstop => "0" })
      expect(results['trades']).to match_array([["2010-07-06", "1", "57.17"]])
    end

    it "should not sell on static holidays" do
      results = run_test(%w(AAPL), '2000-06-10', '2000-07-10', {:longsig => "O = 91.19", :longxsig => "O = 52.13", :longstop => "0" })
      expect(results['trades']).to match_array([["2000-06-14", "2", "47.34", "2000-07-05", "53.25", "12.48"]])

      results = run_test(%w(AAPL), '2014-12-10', '2015-01-10', {:longsig => "L = 106.26", :longxsig => "C = 112.01", :longstop => "0" })
      expect(results['trades']).to match_array([["2014-12-17", "1", "107.12", "2014-12-26", "112.1", "4.64"]])

      results = run_test(%w(AAPL), '2014-12-10', '2015-01-10', {:longsig => "O = 112.10", :longxsig => "O = 112.82", :longstop => "0" })
      expect(results['trades']).to match_array([["2014-12-29", "1", "113.79", "2015-01-02", "111.39", "-2.11"]])

      results = run_test(%w(ABD), '2009-12-20', '2010-01-10', {:longsig => "O = 7.4", :longxsig => "O = 7.65", :longstop => "0" })
      expect(results['trades']).to match_array([["2009-12-23", "1", "7.47", "2009-12-28", "7.66", "2.54"]])
    end
  end

  describe "Stop losses" do
    it "should sell immediately when a stop loss is hit" do
      results = run_test(%w(AAPL), '2015-02-20', '2015-03-20', {:longsig => "H = 133", :longxsig => "H = 0", :longstop => "127" })
      expect(results['trades']).to match_array([["2015-02-24", "1", "132.94", "2015-02-26", "127", "-4.47"]])

      results = run_test(%w(AAPL), '2015-02-20', '2015-03-20', {:longsig => "H = 133.60", :longxsig => "H = 0", :longstop => "123" })
      expect(results['trades']).to match_array([["2015-02-25", "1", "131.56", "2015-03-11", "123", "-6.51"]])
  
      results = run_test(%w(XOM), '2015-01-01', '2015-03-20', {:longsig => "H = 92.97", :longxsig => "H = 0", :longstop => "86.25" })
      expect(results['trades']).to match_array([["2015-01-23", "1", "92.28", "2015-01-29", "86.25", "-6.54"]])

      results = run_test(%w(XOM), '2014-07-20', '2014-08-20', {:longsig => "H = 104.76", :longxsig => "H = 0", :longstop => "98" })
      expect(results['trades']).to match_array([["2014-07-30", "1", "103.73", "2014-08-05", "98", "-5.53"]])
    end
  end

  describe "Stock splits" do
    it "should split adjust positions" do
      results = run_test(%w(AAPL), '2014-06-01', '2014-07-20', {:longsig => "V = 92337700", :longxsig => "O = 90.21", :longstop => "0" })
      expect(results['trades']).to match_array([["2014-06-03", "7", "89.78", "2014-06-26", "90.37", "0.65"]])

#      results = run_test(%w(AAPL), '2005-02-20', '2005-03-20', {:longsig => "O = 86.72", :longxsig => "O = 41.53", :longstop => "0" })
#      expect(results['trades']).to match_array([["2014-06-03", "7", "89.78", "2014-06-26", "90.37", "0.65"]])

#      results = run_test(%w(AAPL), '2000-06-10', '2000-07-10', {:longsig => "O = 91.19", :longxsig => "O = 52.13", :longstop => "0" })
#      expect(results['trades']).to match_array([["2000-06-14", "2", "47.34", "2000-07-04", "52.13", "10.11"]])

      results = run_test(%w(AAPL), '1987-06-10', '1987-07-10', {:longsig => "O = 79", :longxsig => "O = 40.5", :longstop => "0" })
      expect(results['trades']).to match_array([["1987-06-15", "2", "39.5", "1987-06-30", "40.5", "2.53"]])
    end
  end
end
