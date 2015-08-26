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

  if(sys[:longtrail])
    cmdline += " --ltrail '#{sys[:longtrail]}'"
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

    it "should split adjust stop losses" do
      results = run_test(%w(AAPL), '2005-02-20', '2005-03-20', {:longsig => "O = 86.72", :longxsig => "O = 0", :longstop => "L3" })
      expect(results['trades']).to match_array([["2005-02-24","2","44.24","2005-03-03","43.125","-2.53"]])
      expect(results['stops']).to match_array([[43.12, 43.12, 43.12, 43.12, 43.12, 43.12]])

      results = run_test(%w(AAPL), '2014-05-28', '2014-06-28', {:longsig => "O = 626.02", :longxsig => "O = 0", :longstop => "606" })
      expect(results['trades']).to match_array([["2014-05-29","7","89.69"]])
      expect(results['stops']).to match_array([[86.57, 86.57, 86.57, 86.57, 86.57, 86.57, 86.57, 86.57, 86.57, 86.57, 86.57, 86.57, 86.57, 86.57, 86.57, 86.57, 86.57, 86.57, 86.57, 86.57, 86.57, 86.57]])     

      results = run_test(%w(AAPL), '2000-06-10', '2000-07-10', {:longsig => "O = 93.5", :longxsig => "O = 0", :longstop => "89" })
      expect(results['trades']).to match_array([["2000-06-19","2","45.28"]])
      expect(results['stops']).to match_array([[44.5,44.5,44.5,44.5,44.5,44.5,44.5,44.5,44.5,44.5,44.5,44.5,44.5,44.5,44.5]])     
    end 

    it "should reverse split adjust stop losses" do
      results = run_test(%w(SPEX), '2012-08-27', '2012-09-27', {:longsig => "O = 0.5", :longxsig => "O = 0", :longstop => "0.3" })
      expect(results['trades']).to match_array([["2012-08-31", "0", "9.59"]])
      expect(results['stops']).to match_array([[6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6]])     

      results = run_test(%w(SPEX), '2011-04-20', '2011-05-20', {:longsig => "O = 0.3", :longxsig => "O = 0", :longstop => "0.25" })
      expect(results['trades']).to match_array([["2011-04-25", "0", "3"]])
      expect(results['stops']).to match_array([[2.5, 2.5, 2.5, 2.5, 2.5, 2.5, 2.5, 2.5, 2.5, 2.5, 2.5, 2.5, 2.5, 2.5, 2.5, 2.5, 2.5, 2.5, 2.5, 2.5]])     
    end

    it "should sell at the opening price of a gap if the gap is below the stop loss" do
      results = run_test(%w(AAPL), '2014-01-02', '2014-02-03', {:longsig => "O = 544.32", :longxsig => "O = 0", :longstop => "525" })
      expect(results['trades']).to match_array([["2014-01-08","1","538.8","2014-01-28","508.76","-5.58"]])
      expect(results['stops']).to match_array([[525,525,525,525,525,525,525,525,525,525,525,525,525,525,525]])

      results = run_test(%w(AAPL), '2013-09-01', '2013-10-01', {:longsig => "O = 493.1", :longxsig => "O = 0", :longstop => "480" })
      expect(results['trades']).to match_array([["2013-09-04","1","499.56","2013-09-11","467.01","-6.52"]])
      expect(results['stops']).to match_array([[480,480,480,480,480,480]])

      results = run_test(%w(AAPL), '2003-10-01', '2003-10-31', {:longsig => "O = 23.73", :longxsig => "O = 0", :longstop => "24" })
      expect(results['trades']).to match_array([["2003-10-14","1","24.32","2003-10-16","23.8","-2.14"]])
      expect(results['stops']).to match_array([[24,24,24]])
    end 

    it "should not change the stop loss if no trailing stop loss is specified" do
      results = run_test(%w(AAPL), '2000-01-10', '2000-01-20', {:longsig => "O > 0", :longxsig => "O = 0", :longstop => "80" })
      expect(results['trades']).to match_array([["2000-01-11","1","95.94"]])
      expect(results['stops']).to match_array([[80,80,80,80,80,80,80,80]])     

      results = run_test(%w(AAPL), '2015-01-02', '2015-01-22', {:longsig => "O > 0", :longxsig => "O = 0", :longstop => "100" })
      expect(results['trades']).to match_array([["2015-01-05","1","108.29"]])
      expect(results['stops']).to match_array([[100,100,100,100,100,100,100,100,100,100,100,100,100,100]])     
    end
  end

  describe "Trailing Stops" do
    it "should allow trailing stop losses" do
      results = run_test(%w(AAPL), '2003-09-01', '2003-10-20', {:longsig => "O = 23.73", :longxsig => "O = 0", :longtrail => "AVGC20" })
      expect(results['trades']).to match_array([["2003-10-14","1","24.32","2003-10-20","22.42","-7.82"]])
      expect(results['stops']).to match_array([[22.21,22.34,22.36,22.37,22.42]]) 

      results = run_test(%w(AAPL), '2011-01-01', '2011-02-01', {:longsig => "O = 333.99", :longxsig => "O = 0", :longtrail => "AVGC50" })
      expect(results['trades']).to match_array([["2011-01-10","1","338.83"]])
      expect(results['stops']).to match_array([[318.48,319.29,320.09,320.82,321.53,321.53,321.98,322.42,322.7,322.91,323.3,323.79,324.51,325.23,325.92,326.7,327.43]]) 
    end

    it "should split adjust trailing stop losses" do
      results = run_test(%w(AAPL), '2014-05-01', '2014-06-31', {:longsig => "O = 592.34", :longxsig => "O = 0", :longtrail => "AVGC20" })
      expect(results['trades']).to match_array([["2014-05-05","7","84.3","2014-06-20","91.48","8.51"]])
      expect(results['stops']).to match_array([[78.52, 79.03, 79.52, 79.93, 80.37, 80.9, 81.41, 81.95, 82.45, 82.97, 83.49, 84.02, 84.6, 84.88, 85.18, 85.18, 85.41, 85.63, 85.96, 86.25, 86.51, 86.77, 87.13, 87.53, 87.94, 88.44, 88.91, 89.37, 89.74, 90.1, 90.44, 90.72, 91.01, 91.28, 91.48]]) 

      results = run_test(%w(AAPL), '2005-02-20', '2005-03-20', {:longsig => "O = 86.72", :longxsig => "O = 0", :longtrail => "L5" })
      expect(results['trades']).to match_array([["2005-02-24","2","44.24","2005-03-03","43.86","-0.86"]])
      expect(results['stops']).to match_array([[43.67, 43.72, 43.72, 43.72, 43.72, 43.86]])

      results = run_test(%w(AAPL), '2000-06-10', '2000-07-10', {:longsig => "O = 93.5", :longxsig => "O = 0", :longtrail => "BOLLINGER_LOWER" })
      expect(results['trades']).to match_array([["2000-06-19", "2", "45.28"]])
      expect(results['stops']).to match_array([[41.85, 41.85, 41.85, 41.85, 41.85, 41.85, 41.85, 41.94, 42.49, 42.79, 43.21, 43.63, 43.82, 44.07, 44.09]])     
    end

    it "should reverse split adjust stop losses" do
      results = run_test(%w(SPEX), '2012-08-27', '2012-09-27', {:longsig => "O = 0.5", :longxsig => "O = 0", :longtrail => "L - 0.2" })
      expect(results['trades']).to match_array([["2012-08-31", "0", "9.59", "2012-09-27", "10.27", "7.09"]])
      expect(results['stops']).to match_array([[5.4, 5.4, 5.4, 5.4, 5.4, 5.4, 5.4, 5.4, 5.4, 5.4, 5.4, 5.4, 5.4, 5.8, 5.8, 5.8, 10.02, 10.11, 11.13, 11.13]])     

      results = run_test(%w(SPEX), '2011-04-20', '2011-05-20', {:longsig => "O = 0.3", :longxsig => "O = 0", :longtrail => "L - 0.2" })
      expect(results['trades']).to match_array([["2011-04-25", "0", "3", "2011-05-18", "3.08", "2.66"]])
      expect(results['stops']).to match_array([[0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 2.9, 2.9, 3.2, 3.59, 3.59, 3.69, 3.7, 3.7]])     
    end

    it "should sell at the opening price of a gap if the gap is below the stop loss" do
      results = run_test(%w(AAPL), '2014-01-01', '2014-02-01', {:longsig => "O = 529.91", :longxsig => "O = 0", :longtrail => "MINL5" })
      expect(results['trades']).to match_array([["2014-01-14","1","538.22","2014-01-28","508.76","-5.48"]])
      expect(results['stops']).to match_array([[529.88,529.88,529.88,529.88,529.88,529.88,537.65,539.9,539.9,539.9,539.9]]) 

      results = run_test(%w(AAPL), '2014-01-01', '2014-02-01', {:longsig => "O = 529.91", :longxsig => "O = 0", :longtrail => "AVGC100" })
      expect(results['trades']).to match_array([["2014-01-14","1","538.22","2014-01-28","508.76","-5.48"]])
      expect(results['stops']).to match_array([[517.96,518.5,519.03,519.41,519.41,520.02,520.62,521.27,521.86,522.47,522.55]]) 

      results = run_test(%w(AAPL), '2013-09-01', '2013-10-01', {:longsig => "O = 493.1", :longxsig => "O = 0", :longtrail => "BOLLINGER_LOWER" })
      expect(results['trades']).to match_array([["2013-09-04","1","499.56","2013-09-11","467.01","-6.52"]])
      expect(results['stops']).to match_array([[459.43, 463.13, 468.59, 478.14, 485.21, 485.21]])

      results = run_test(%w(AAPL), '2003-10-01', '2003-10-31', {:longsig => "O = 23.73", :longxsig => "O = 0", :longtrail => "AVGC5" })
      expect(results['trades']).to match_array([["2003-10-14","1","24.32","2003-10-16","23.8","-2.14"]])
      expect(results['stops']).to match_array([[23.81, 24.17, 24.17]])
    end
  end

  describe "Equity curve" do
    it "should have an entry for every day of the test" do
      results = run_test(%w(AAPL), '2015-01-01', '2015-01-08', {:longsig => "O < 0", :longxsig => "O = 0", :longtrail => "0" })
      expect(results['equity']).to match_array([10_000, 10_000, 10_000, 10_000, 10_000]) 

      results = run_test(%w(AAPL), '2015-01-01', '2015-01-15', {:longsig => "O < 0", :longxsig => "O = 0", :longtrail => "0" })
      expect(results['equity']).to match_array([10_000, 10_000, 10_000, 10_000, 10_000, 10_000, 10_000, 10_000, 10_000, 10_000]) 

      results = run_test(%w(AAPL), '2015-03-01', '2015-03-25', {:longsig => "O < 0", :longxsig => "O = 0", :longtrail => "0" })
      expect(results['equity']).to match_array([10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000,10000]) 
    end

    it "should not change until a position is opened" do
      results = run_test(%w(AAPL), '2015-03-01', '2015-03-20', {:longsig => "O = 128.4", :longxsig => "O = 0", :longstop => "0" })
      expect(results['equity']).to match_array([9994.28, 9995.63, 9996.49, 9996.55, 9996.99, 9997.94, 9999.08, 9999.18, 9999.54, 10000.0, 10000.0, 10000.0, 10000.0, 10000.0, 10000.51]) 
 
      results = run_test(%w(AAPL), '2015-03-01', '2015-03-20', {:longsig => "O = 124.4", :longxsig => "O = 0", :longstop => "0" })
      expect(results['equity']).to match_array([10000.0, 10000.0, 10000.0, 10000.0, 10000.0, 10000.0, 10000.0, 10000.0, 10000.0, 10000.0, 10001.07, 10002.02, 10003.16, 10003.62, 10004.59]) 

      results = run_test(%w(AAPL), '2015-03-01', '2015-03-20', {:longsig => "O = 128.96", :longxsig => "O = 0", :longstop => "0" })
      expect(results['equity']).to match_array([10000,10000,9999.44,9997.31,9997.5,9998.04,9995.41,9993.14,9995.35,9994.49,9995.85,9997.94,9999.37,9998.4,9996.8]) 
    end

    it "should not change after a position is closed" do
      results = run_test(%w(AAPL), '2015-03-01', '2015-03-20', {:longsig => "O = 128.4", :longxsig => "O = 125.9", :longstop => "0" })
      expect(results['equity']).to match_array([9994.28, 9995.63, 9996.49, 9996.55, 9996.99, 9999.08, 9999.18, 10000.0, 10000.0, 10000.0, 10000.0, 10000.0, 10000.51, 10000.51, 10000.51]) 
 
      results = run_test(%w(AAPL), '2015-03-01', '2015-03-20', {:longsig => "O = 124.4", :longxsig => "O = 127", :longstop => "0" })
      expect(results['equity']).to match_array([10000.0, 10000.0, 10000.0, 10000.0, 10000.0, 10000.0, 10000.0, 10000.0, 10000.0, 10000.0, 10001.07, 10003.16, 10003.62, 10003.62, 10004.59]) 

      results = run_test(%w(AAPL), '2015-03-01', '2015-03-20', {:longsig => "O = 128.96", :longxsig => "O = 128.4", :longstop => "0" })
      expect(results['equity']).to match_array([10000,10000,9999.44,9997.31,9997.5,9998.04,9998.04,9998.04,9998.04,9998.04,9998.04,9998.04,9998.04,9998.04,9998.04]) 
    end

    it "should behave sanely during stock splits" do
      results = run_test(%w(AAPL), '2014-05-01', '2014-06-31', {:longsig => "O = 592.34", :longxsig => "O = 0", :longtrail => "AVGC20" })
      expect(results['equity']).to match_array([9995.4, 9997.85, 9998.68, 10000.0, 10000.0, 10002.19, 10002.69, 10003.62, 10003.73, 10004.27, 10007.37, 10010.82, 10014.45, 10014.57, 10016.16, 10017.13, 10023.99, 10023.99, 10033.87, 10035.49, 10038.51, 10042.86, 10045.24, 10046.23, 10046.23, 10046.23, 10046.23, 10046.23, 10046.23, 10046.23, 10047.4, 10048.82, 10052.88, 10054.42, 10054.68, 10055.12, 10055.26, 10055.43, 10055.89, 10057.21, 10065.76, 10066.88, 10069.61]) 

      results = run_test(%w(AAPL), '2005-02-20', '2005-03-20', {:longsig => "O = 86.72", :longxsig => "O = 0", :longtrail => "L5" })
      expect(results['equity']).to match_array([9995.1, 9995.1, 9995.1, 9995.1, 9995.1, 9995.1, 9995.1, 9995.1, 9995.1, 9995.1, 9995.1, 9995.1, 9999.76, 10000.0, 10000.0, 10000.0, 10000.45, 10000.51, 10000.52, 10001.24])

      results = run_test(%w(AAPL), '2000-06-10', '2000-07-10', {:longsig => "O = 93.5", :longxsig => "O = 0", :longtrail => "BOLLINGER_LOWER" })
      expect(results['equity']).to match_array([10000.0, 10000.0, 10000.0, 10000.0, 10000.0, 10006.06, 10010.69, 10011.94, 10012.7, 10012.82, 10012.94, 10013.06, 10014.2, 10016.06, 10016.94, 10017.7, 10018.32, 10018.32, 10020.7, 10023.7])
    end

    it "should behave sanely during reverse stock splits" do
      results = run_test(%w(SPEX), '2012-08-27', '2012-09-27', {:longsig => "O = 0.5", :longxsig => "O = 0", :longtrail => "L - 0.2" })
      expect(results['trades']).to match_array([["2012-08-31", "0", "9.59", "2012-09-27", "10.27", "7.09"]])
      expect(results['equity']).to match_array([9999.92, 9999.94, 9999.95, 9999.95, 9999.96, 9999.97, 9999.97, 9999.98, 9999.98, 10000.0, 10000.0, 10000.0, 10000.0, 10000.0, 10000.01, 10000.01, 10000.02, 10000.02, 10000.03, 10000.03, 10000.03, 10000.03, 10000.05, 10000.06])     

      results = run_test(%w(SPEX), '2011-04-20', '2011-05-20', {:longsig => "O = 0.3", :longxsig => "O = 0", :longtrail => "L - 0.2" })
      expect(results['trades']).to match_array([["2011-04-25", "0", "3", "2011-05-18", "3.08", "2.66"]])
      expect(results['equity']).to match_array([9999.98, 9999.98, 9999.98, 9999.98, 9999.98, 10000.0, 10000.0, 10000.0, 10000.0, 10000.0, 10000.0, 10000.01, 10000.01, 10000.01, 10000.01, 10000.01, 10000.01, 10000.01, 10000.01, 10000.01, 10000.01, 10000.01, 10000.01])
    end
  end

  describe "Portfolio metrics" do
    it "should track equity" do
      results = run_test(%w(AAPL), '2005-02-20', '2005-03-20', {:longsig => "O = 86.72", :longxsig => "PORTFOLIO_EQUITY = 10001.24", :longstop => "0" })
      expect(results['trades']).to match_array([["2005-02-24","2","44.24","2005-03-02","44.25","0.02"]])
      expect(results['equity']).to match_array([10000.00,10000.00,10000.00,10000.45,10000.51,10001.24,10000.52,9999.76,9999.76,9999.76,9999.76,9999.76,9999.76,9999.76,9999.76,9999.76,9999.76,9999.76,9999.76,9999.76])

      results = run_test(%w(AAPL), '2005-02-20', '2005-03-20', {:longsig => "O = 86.72", :longxsig => "PORTFOLIO_EQUITY = 9999.76", :longstop => "0" })
      expect(results['trades']).to match_array([["2005-02-24","2","44.24","2005-03-04","42.76","-3.35"]])
      expect(results['equity']).to match_array([10000.00,10000.00,10000.00,10000.45,10000.51,10001.24,10000.52,9999.76,9995.10,9997.14,9997.14,9997.14,9997.14,9997.14,9997.14,9997.14,9997.14,9997.14,9997.14,9997.14])
    end

    it "should track total return" do
      results = run_test(%w(AAPL), '2005-02-20', '2005-03-20', {:longsig => "O = 86.72", :longxsig => "PORTFOLIO_RETURN = 0.01", :longstop => "0" })
      expect(results['trades']).to match_array([["2005-02-24","2","44.24","2005-03-02","44.25","0.02"]])
      expect(results['equity']).to match_array([10000.00,10000.00,10000.00,10000.45,10000.51,10001.24,10000.52,9999.76,9999.76,9999.76,9999.76,9999.76,9999.76,9999.76,9999.76,9999.76,9999.76,9999.76,9999.76,9999.76])

      results = run_test(%w(XOM), '2005-02-20', '2005-03-20', {:longsig => "O = 59.5", :longxsig => "PORTFOLIO_RETURN = 0.03", :longstop => "0" })
      expect(results['trades']).to match_array([["2005-02-23","1","58.5","2005-03-03","62.7","7.17"]])
      expect(results['equity']).to match_array([10000.00,10000.00,10000.92,10002.63,10004.76,10004.81,10003.60,10004.18,10004.55,10004.55,10004.55,10004.55,10004.55,10004.55,10004.55,10004.55,10004.55,10004.55,10004.55,10004.55])
    end

    it "should track remaining cash" do
      results = run_test(%w(AAPL XOM), '2005-02-20', '2005-03-20', {:longsig => "O > 0", :longxsig => "PORTFOLIO_CASH = 9854.2", :longstop => "0" })
     
      expect(results['trades']).to match_array([["2005-02-22","1","59.5","2005-02-23","58.5","-1.69"],["2005-02-22","1","86.3","2005-02-23","86.72","0.48"],["2005-02-24","1","59.6"],["2005-02-24","2","44.24"]])

      expect(results['equity']).to match_array([10000.00,9997.74,10001.85,10003.83,10006.02,10006.80,10004.87,10004.69,10000.40,10002.96,10002.27,9997.93,9993.26,9993.80,9995.36,9995.69,9996.04,9996.42,9999.76,10002.34])
    end

    it "should track the number of positions" do
      results = run_test(%w(AAPL XOM), '2005-02-20', '2005-03-20', {:longsig => "O > 0", :longxsig => "PORTFOLIO_POSITION_COUNT = 2", :longstop => "0" })

      expect(results['trades']).to match_array([["2005-02-22","1","59.5","2005-02-23","58.5","-1.69"],["2005-02-22","1","86.3","2005-02-23","86.72","0.48"],["2005-02-24","1","59.6","2005-02-25","61.5","3.18"],["2005-02-24","1","88.48","2005-02-25","89.62","1.28"],["2005-02-28","1","63.26","2005-03-01","62.97","-0.46"],["2005-02-28","1","44.68","2005-03-01","44.99","0.69"],["2005-03-02","1","62.05","2005-03-03","62.7","1.04"],["2005-03-02","1","44.25","2005-03-03","44.37","0.27"],["2005-03-04","1","63.12","2005-03-07","63.58","0.72"],["2005-03-04","1","42.76","2005-03-07","42.8","0.09"],["2005-03-08","1","63.15","2005-03-09","63.1","-0.08"],["2005-03-08","1","41.9","2005-03-09","39.64","-5.4"],["2005-03-10","1","60.9","2005-03-11","60.37","-0.88"],["2005-03-10","1","39.53","2005-03-11","40.21","1.72"],["2005-03-14","1","61.06","2005-03-15","61.29","0.37"],["2005-03-14","1","40.52","2005-03-15","40.64","0.29"],["2005-03-16","1","60","2005-03-17","60.88","1.46"],["2005-03-16","1","41.21","2005-03-17","41.53","0.77"],["2005-03-18","1","61.59"],["2005-03-18","1","43.33"]])

      expect(results['equity']).to match_array([10000.00,9997.74,10001.85,10003.83,10006.02,10006.25,10004.68,10005.18,10003.22,10003.72,10003.09,10001.67,9998.18,9997.95,9999.07,9999.09,9998.80,9999.06,10001.33,10002.02])
    end
  end

  describe "Stock splits" do
    it "should split adjust positions" do
      results = run_test(%w(AAPL), '2014-06-01', '2014-07-20', {:longsig => "V = 92337700", :longxsig => "O = 90.21", :longstop => "0" })
      expect(results['trades']).to match_array([["2014-06-03", "7", "89.78", "2014-06-26", "90.37", "0.65"]])

      results = run_test(%w(AAPL), '2005-02-20', '2005-03-20', {:longsig => "O = 86.72", :longxsig => "O = 41.53", :longstop => "0" })
      expect(results['trades']).to match_array([["2005-02-24", "2", "44.24", "2005-03-18", "43.33", "-2.06"]])

      results = run_test(%w(AAPL), '2000-06-10', '2000-07-10', {:longsig => "O = 91.19", :longxsig => "O = 52.13", :longstop => "0" })
      expect(results['trades']).to match_array([["2000-06-14", "2", "47.34", "2000-07-05", "53.25", "12.48"]])

      results = run_test(%w(AAPL), '1987-06-10', '1987-07-10', {:longsig => "O = 79", :longxsig => "O = 40.5", :longstop => "0" })
      expect(results['trades']).to match_array([["1987-06-15", "2", "39.5", "1987-06-30", "40.5", "2.53"]])
    end
  end
end
