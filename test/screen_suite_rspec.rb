require 'digest/md5'

HOMEDIR = Dir.pwd
CHECKSUMS = {
	'XOM' => '476e204633ab2f656be1dae36658cd17', 
	'IWM' => '509877764a69ef70773c7adfdbe5b40b', 
	'HBI' => 'b8313f5d4da3e2af92a312f815b730e8',
	'ABD' => 'b1ff397823c133d21d81b9fb12c73b57',
	'AAPL' => '9311faba6c4bb734645ee58dfcb0a9e4',
	'IKAN' => 'cd6305889f082302c865fbe01be716df',
	'FLEX' => 'c647090608d10ce02fd379cddc031768',
	'ABV-C' => '8dd6bb7329a71449b0a1b292b5999164',
	} 

def run_screen(screen, tickers, date)
  Dir.chdir("../ui/cmdline")
  cmdline = "./screen.rb -t #{tickers.join(',')} -d #{date} -c \"#{screen}\""
  output = `#{cmdline}`
  Dir.chdir(HOMEDIR)
  output.split 
end

RSpec.describe "Dates and data handling" do

  before(:each) do
   Dir.chdir(HOMEDIR)
  end

  it "ptab files are free of corruption" do
    CHECKSUMS.each do |t, x|
      md5 = Digest::MD5.hexdigest(File.read("./testdata/#{t}.ptab"))
      expect(md5).to eq(x)
    end
  end

  it "screens data at the given date" do
    hits = run_screen("O = 84.54; H = 84.85; L = 84.02; C = 84.08; V = 12957300", %w(XOM), "2015-03-17")
    expect(hits).to match_array(%w(XOM))

    hits = run_screen("O = 122.55; H = 123.78; L = 122.53; C = 123.47; V = 29018800", %w(IWM), "2015-03-02")
    expect(hits).to match_array(%w(IWM))

    hits = run_screen("O = 84.46; H = 85.42; L = 83.11; C = 85.1; V = 643500;", %w(HBI), "2014-06-04")
    expect(hits).to match_array(%w(HBI))

    hits = run_screen("O = 551.48; H = 552.07; L = 539.90; C = 540.66; V = 15240700", %w(AAPL), "2014-01-17")
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("O20 = 3.5; L = 3.3;", %w(IKAN), "2015-02-28")
    expect(hits).to match_array(%w(IKAN))
  end

  it "finds leap days" do
    hits = run_screen("O = 129.29; H = 130.21; L = 124.8; C = 125.02;", %w(AAPL), "2008-02-29");
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("O = 541.55; H = 547.61; L = 535.7; C = 542.44;", %w(AAPL), "2012-02-29");
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("O = 87.45; H = 87.49; L = 86.21; C = 86.5; V = 18293200;", %w(XOM), "2012-02-29");
    expect(hits).to match_array(%w(XOM))

    hits = run_screen("O = 88.77; H = 89.29; L = 86.25; C = 87.01; V = 26540200", %w(XOM), "2008-02-29");
    expect(hits).to match_array(%w(XOM))

    hits = run_screen("O = 4.63; H = 4.63; L = 4.53; C = 4.55; V = 56800;", %w(IKAN), "2008-02-29")
    expect(hits).to match_array(%w(IKAN))

    hits = run_screen("O = 0.78; H = 0.78; L = 0.75; C = 0.75; V = 22600;", %w(IKAN), "2012-02-29");
    expect(hits).to match_array(%w(IKAN))
  end

  it "discards data older than 10 business days when run during a business day" do
    hits = run_screen("C > 0;", %w(AAPL), "2015-04-06")
    expect(hits).to be_empty

    hits = run_screen("C > 0;", %w(XOM), "2015-04-20")
    expect(hits).to be_empty

    hits = run_screen("C > 0;", %w(IKAN), "2015-05-01")
    expect(hits).to be_empty

    hits = run_screen("C > 0;", %w(IWM), "2015-05-05")
    expect(hits).to be_empty
  end

  it "discards data older than 10 business days when run during a weekend" do
    hits = run_screen("C > 50;", %w(AAPL), "2015-04-04")
    expect(hits).to be_empty

    hits = run_screen("C > 0;", %w(XOM), "2015-04-18")
    expect(hits).to be_empty

    hits = run_screen("C > 0;", %w(XOM), "2015-04-19")
    expect(hits).to be_empty

    hits = run_screen("C > 0;", %w(IKAN), "2015-05-02")
    expect(hits).to be_empty

    hits = run_screen("C > 0;", %w(IKAN), "2015-05-03")
    expect(hits).to be_empty

    hits = run_screen("C > 0;", %w(IWM), "2015-05-09")
    expect(hits).to be_empty

    hits = run_screen("C > 0;", %w(IWM), "2015-05-10")
    expect(hits).to be_empty
  end

  it "does not discard data younger than 10 business days" do
    hits = run_screen("C > 0;", %w(AAPL), "2015-03-25")
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("C > 0;", %w(XOM), "2015-03-25")
    expect(hits).to match_array(%w(XOM))

    hits = run_screen("C > 0;", %w(IKAN), "2015-03-25")
    expect(hits).to match_array(%w(IKAN))
  end

  it "handles a mixed list of stocks younger and older than 10 business days" do
    hits = run_screen("C > 0;", %w(AAPL XOM IKAN ABD), "2013-01-03")
    expect(hits).to match_array(%w(AAPL XOM IKAN))
  end

  it "discards data with a gap of more than 5 business days" do
    #HBI, IWM, and XOM have 10 day gaps from 2015-02-10 to 2015-02-20
    hits = run_screen("C100 > 0;", %w(XOM HBI IWM), "2015-03-23")
    expect(hits).to be_empty

    hits = run_screen("ATR40 > 0;", %w(XOM), "2015-03-13")
    expect(hits).to be_empty
  end

  it "handles a mixed list of stocks with and without gaps" do
    hits = run_screen("C100 > 0;", %w(XOM HBI IWM AAPL IKAN), "2015-03-23")
    expect(hits).to match_array(%w(AAPL IKAN))
  end

  it "discards data when there isn't enough to run a rule" do
    hits = run_screen("C10 > 0;", %w(AAPL), "1984-09-12")
    expect(hits).to be_empty

    hits = run_screen("C10 > 0;", %w(XOM), "1970-01-07")
    expect(hits).to be_empty

    hits = run_screen("C10 > 0;", %w(IWM), "2000-06-02")
    expect(hits).to be_empty

    hits = run_screen("C10 > 0;", %w(IKAN), "2005-09-27")
    expect(hits).to be_empty
  end

  describe "split adjustments" do 

    it "processes adjustments" do
      hits = run_screen("O20 = 3.5;", %w(IKAN), "2015-02-28")
      expect(hits).to match_array(%w(IKAN))

      hits = run_screen("O10 = 39; H10 = 39.56;", %w(FLEX), "2000-10-19")
      expect(hits).to match_array(%w(FLEX)) 

      hits = run_screen("O10 = 78; H10 = 79.12;", %w(FLEX), "2000-10-19")
      expect(hits).to be_empty
    end
  
    it "processes multiple adjustments for a single pull" do
      hits = run_screen("O210 = 20.875; H210 = 20.9375;", %w(FLEX), "2000-10-19")
      expect(hits).to match_array(%w(FLEX))
    end
  
    it "processes multiple adjustments across multiple pulls" do
      hits = run_screen("C5 > 0; O210 = 20.875; H210 = 20.9375;", %w(FLEX), "2000-10-19")
      expect(hits).to match_array(%w(FLEX))
    end
  
    it "applies splits starting on the right day" do
      hits = run_screen("O = 92.7; H = 93.88; L = 91.75; C= 93.7;", %w(AAPL), "2014-06-09")
      expect(hits).to match_array(%w(AAPL))

      hits = run_screen("O1 > 92.84; H1 > 93.03; L1 > 92.06; C1 > 92.22;", %w(AAPL), "2014-06-09")
      expect(hits).to match_array(%w(AAPL))

      hits = run_screen("O = 50.5; H = 56.94; L = 50.31; C = 55.63;", %w(AAPL), "2000-06-21")
      expect(hits).to match_array(%w(AAPL))

      hits = run_screen("O1 = 49.25; H1 = 51.97; L1 = 49.185; C1 = 50.625;", %w(AAPL), "2000-06-21")
      expect(hits).to match_array(%w(AAPL))

      hits = run_screen("O1 = 98.5; H1 = 103.94; L1 = 98.37; C1 = 101.25;", %w(AAPL), "2000-06-21")
      expect(hits).to be_empty
    end
  
    it "does not alter dates when splitting" do
  
    end

    it "does not alter volume when splitting" do
      hits = run_screen("V = 87484600;", %w(AAPL), "2014-06-06")
      expect(hits).to match_array(%w(AAPL))

      hits = run_screen("V = 17922000;", %w(AAPL), "2000-06-20")
      expect(hits).to match_array(%w(AAPL))

      hits = run_screen("V = 32696800;", %w(AAPL), "2005-02-25")
      expect(hits).to match_array(%w(AAPL))

      hits = run_screen("V = 9280000;", %w(AAPL), "1987-06-15")
      expect(hits).to match_array(%w(AAPL))
      
      hits = run_screen("V = 19600;", %w(IKAN), "2015-02-13")
      expect(hits).to match_array(%w(IKAN))
    end
  end

  it "behaves correctly at start boundary" do
    hits = run_screen("O = 26.50; H = 26.87; L = 26.25; C = 26.50; V = 2981600;", %w(AAPL), "1984-09-07")
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("O = 61.75; H = 62; L = 61.63; C = 62; V = 1296000;", %w(XOM), "1970-01-02")
    expect(hits).to match_array(%w(XOM))

    hits = run_screen("O = 91.06; H = 91.44; L = 90.62; C = 91.44; V = 74800;", %w(IWM), "2000-05-26")
    expect(hits).to match_array(%w(IWM))

    hits = run_screen("O = 19.8; H = 21.34; L = 19.55; C = 21.11; V = 7646000;", %w(HBI), "2006-09-06")
    expect(hits).to match_array(%w(HBI))

    hits = run_screen("O = 13.3; H = 14.25; L = 12.8; C = 13; V = 5327800;", %w(IKAN), "2005-09-22")
    expect(hits).to match_array(%w(IKAN))
  end

  it "discards date requests that are out of bounds" do
    hits = run_screen("O = 26.50; H = 26.87; L = 26.25; C = 26.50; V = 2981600;", %w(AAPL), "1984-09-01")
    expect(hits).to be_empty 

    hits = run_screen("O = 61.75; H = 62; L = 61.63; C = 62; V = 1296000;", %w(XOM), "1969-12-30")
    expect(hits).to be_empty 

    hits = run_screen("O = 91.06; H = 91.44; L = 90.62; C = 91.44; V = 74800;", %w(IWM), "2000-05-23")
    expect(hits).to be_empty 

    hits = run_screen("O = 19.8; H = 21.34; L = 19.55; C = 21.11; V = 7646000;", %w(HBI), "2006-09-05")
    expect(hits).to be_empty 

    hits = run_screen("O = 13.3; H = 14.25; L = 12.8; C = 13; V = 5327800;", %w(IKAN), "2005-09-20")
    expect(hits).to be_empty
  end

  it "pulls the previous business day of data for Saturdays" do
    hits = run_screen("O = 98.81; C = 99.74; V = 11199300;", %w(XOM), "2014-08-09")
    expect(hits).to match_array(%w(XOM))

    hits = run_screen("O = 100.76; C = 101.99; V = 433900;", %w(HBI), "2014-08-23")
    expect(hits).to match_array(%w(HBI))

    hits = run_screen("O = 574.58; C = 570.52; V = 11900000;", %w(AAPL), "2012-05-10")
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("O = 1.45; C = 1.42; V = 176500;", %w(IKAN), "2011-01-08")
    expect(hits).to match_array(%w(IKAN))
  end

  it "pulls the previous business day of data for Sundays" do
    hits = run_screen("O = 101.71; H = 102.18; L = 101.26; C = 101.95; V = 8948800;", %w(XOM), "2014-05-11")
    expect(hits).to match_array(%w(XOM))

    hits = run_screen("O = 28.11; H = 28.36; L = 27.98; C = 28.10; V = 718700;", %w(HBI), "2012-06-24")
    expect(hits).to match_array(%w(HBI))

    hits = run_screen("O = 540.41; H = 554.88; L = 533.72; C = 547.05; V = 33200500;", %w(AAPL), "2012-11-11")
    expect(hits).to match_array(%w(AAPL))
    
    hits = run_screen("O = 1.34; H = 1.43; L = 1.34; C = 1.42; V = 92400;", %w(IKAN), "2012-10-30")
    expect(hits).to match_array(%w(IKAN))
  end

  it "detects price differences of one cent" do
    hits = run_screen("O = 123.88;", %w(AAPL), "2015-03-16")
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("O = 123.89;", %w(AAPL), "2015-03-16")
    expect(hits).to be_empty

    hits = run_screen("O = 123.87;", %w(AAPL), "2015-03-16")
    expect(hits).to be_empty
  end
end

RSpec.describe "Indicators" do

  it "Minimum Close" do
    hits = run_screen("MINC50 = 1.61;", %w(IKAN), "2010-01-12")
    expect(hits).to match_array(%w(IKAN))

    hits = run_screen("MINC200 = 1.03;", %w(IKAN), "2009-09-15")
    expect(hits).to match_array(%w(IKAN))
    
    hits = run_screen("MINC100 = 50.67;", %w(AAPL), "2006-09-26")
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("MINC20 = 13.12;", %w(AAPL), "2003-05-08")
    expect(hits).to match_array(%w(AAPL))
  end

  it "Maximum Close" do
    hits = run_screen("MAXC50 = 567.90;", %w(AAPL), "2013-12-16")
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("MAXC260 = 702.10;", %w(AAPL), "2012-10-01")
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("MAXC100 = 636.23;", %w(AAPL), "2012-05-18")
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("MAXC50 = 1.5;", %w(IKAN), "2012-11-14")
    expect(hits).to match_array(%w(IKAN))

    hits = run_screen("MAXC300 = 3.41;", %w(IKAN), "2010-07-01")
    expect(hits).to match_array(%w(IKAN))
  end

  it "Average Volume" do
    hits = run_screen("AVGV20 = 58827025;", %w(AAPL), "2015-03-02")
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("AVGV200 = 19129470;", %w(AAPL), "2012-12-03")
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("AVGV100 = 20846127;", %w(AAPL), "2011-11-11")
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("AVGV21 = 24065034;", %w(XOM), "2012-06-25")
    expect(hits).to match_array(%w(XOM))

    hits = run_screen("AVGV50 = 20625078;", %w(XOM), "2012-01-03")
    expect(hits).to match_array(%w(XOM))
  end

  it "Average True Range" do
    hits = run_screen("ATR = ATR14", %w(AAPL XOM IKAN), "2015-03-16")
    expect(hits).to match_array(%w(AAPL XOM IKAN))

    hits = run_screen("ATR > 2.86; ATR < 2.87;", %w(AAPL), "2015-03-16")
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("ATR20 > 2.57; ATR20 < 2.58;", %w(AAPL), "2015-03-16")
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("ATR50 > 2.804; ATR50 < 2.805;", %w(AAPL), "2015-03-16")
    expect(hits).to match_array(%w(AAPL)) 

    hits = run_screen("ATR50 = 6.0008;", %w(AAPL), "2010-11-17")
    expect(hits).to match_array(%w(AAPL)) 

    hits = run_screen("ATR20 > 5.623; ATR20 < 5.624;", %w(AAPL), "2010-11-17")
    expect(hits).to match_array(%w(AAPL)) 

    hits = run_screen("ATR > 5.7971; ATR < 5.7972;", %w(AAPL), "2010-11-17")
    expect(hits).to match_array(%w(AAPL)) 

    hits = run_screen("ATR > 1.0564; ATR < 1.0565;", %w(XOM), "2015-03-13")
    expect(hits).to match_array(%w(XOM))

    hits = run_screen("ATR20 > 2.025; ATR20 < 2.026;", %w(XOM), "2015-02-02")
    expect(hits).to match_array(%w(XOM))

    hits = run_screen("ATR50 > 2.018; ATR50 < 2.019;", %w(XOM), "2015-02-02")
    expect(hits).to match_array(%w(XOM))
  end

  it "Relative Strength Index" do
    hits = run_screen("RSI = RSI14", %w(AAPL XOM IKAN), "2013-09-17")
    expect(hits).to match_array(%w(AAPL XOM IKAN))

    hits = run_screen("RSI > 38.860; RSI < 38.861;", %w(AAPL), "2013-09-17")
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("RSI > 55.38; RSI < 55.39;", %w(AAPL), "2005-12-30")
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("RSI40 > 44.636; RSI40 < 44.637;", %w(AAPL), "2014-02-03")
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("RSI40 > 64.186; RSI40 < 64.187;", %w(AAPL), "2012-09-21")
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("RSI > 51.8; RSI < 51.9;", %w(XOM), "2015-01-21")
    expect(hits).to match_array(%w(XOM))

    hits = run_screen("RSI50 > 47.9; RSI50 < 48;", %w(XOM), "2015-01-21")
    expect(hits).to match_array(%w(XOM))

    hits = run_screen("RSI100 > 48.02; RSI100 < 48.03;", %w(XOM), "2015-01-21")
    expect(hits).to match_array(%w(XOM))
  end

  it "Simple Moving Average" do
    hits = run_screen("AVGC20 = 545.037;", %w(AAPL), "2014-01-28")
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("AVGC200 > 483.11; AVGC200 < 483.13;", %w(AAPL), "2014-01-28")
    expect(hits).to match_array(%w(AAPL))
    
    hits = run_screen("AVGC20 = 38.3225;", %w(AAPL), "2004-10-13")
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("AVGC200 = 29.0594;", %w(AAPL), "2004-10-13")
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("AVGC200 = 97.9015;", %w(XOM), "2014-11-10")
    expect(hits).to match_array(%w(XOM))

    hits = run_screen("AVGC20 = 93.9135;", %w(XOM), "2014-11-10")
    expect(hits).to match_array(%w(XOM))

    hits = run_screen("AVGC200 = 67.497;", %w(XOM), "2010-07-02")
    expect(hits).to match_array(%w(XOM))

    hits = run_screen("AVGC20 = 60.388;", %w(XOM), "2010-07-02")
    expect(hits).to match_array(%w(XOM))
  end

  it "Exponential Moving Average" do
    hits = run_screen("EMAC100 > 91.54; EMAC100 < 91.55;", %w(XOM), "2013-12-18")
    expect(hits).to match_array(%w(XOM))

    hits = run_screen("EMAC50 > 93.02; EMAC50 < 93.03;", %w(XOM), "2013-12-18")
    expect(hits).to match_array(%w(XOM))

    hits = run_screen("EMAC20 > 95.25; EMAC20 < 95.26;", %w(XOM), "2013-12-18")
    expect(hits).to match_array(%w(XOM))

    hits = run_screen("EMAC20 > 1.35; EMAC20 < 1.36;", %w(IKAN), "2012-10-17")
    expect(hits).to match_array(%w(IKAN))

    hits = run_screen("EMAC50 > 1.18; EMAC50 < 1.19;", %w(IKAN), "2012-10-17")
    expect(hits).to match_array(%w(IKAN))

    hits = run_screen("EMAC200 > 0.983; EMAC200 < 0.984;", %w(IKAN), "2012-10-17")
    expect(hits).to match_array(%w(IKAN))
  end

  it "Weighted Moving Average" do
    hits = run_screen("WMAC200 > 0.963; WMAC200 < 0.964;", %w(IKAN), "2012-10-17")
    expect(hits).to match_array(%w(IKAN))

    hits = run_screen("WMAC50 > 1.237; WMAC50 < 1.238;", %w(IKAN), "2012-10-17")
    expect(hits).to match_array(%w(IKAN))

    hits = run_screen("WMAC100 > 1.084; WMAC100 < 1.085;", %w(IKAN), "2012-10-17")
    expect(hits).to match_array(%w(IKAN))

    hits = run_screen("WMAC50 > 11.724; WMAC50 < 11.725;", %w(ABD), "2012-04-30")
    expect(hits).to match_array(%w(ABD))

    hits = run_screen("WMAC200 > 10.07; WMAC200 < 10.08;", %w(ABD), "2012-04-30")
    expect(hits).to match_array(%w(ABD))

    hits = run_screen("WMAC300 > 9.34; WMAC300 < 9.35;", %w(ABD), "2012-04-30")
    expect(hits).to match_array(%w(ABD))
  end

  it "Normalized Average True Range" do
    hits = run_screen("NATR > 3.85; NATR < 3.86;", %w(AAPL), "2012-04-30")
    expect(hits).to match_array(%w(AAPL))
    
    hits = run_screen("NATR > 1.864; NATR < 1.865;", %w(AAPL), "2010-08-11")
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("NATR30 > 2.993; NATR30 < 2.994;", %w(AAPL), "2013-01-02")
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("NATR30 > 1.632; NATR30 < 1.633;", %w(AAPL), "2014-01-02")
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("NATR > 2.22; NATR < 2.23;", %w(XOM), "2015-02-02")
    expect(hits).to match_array(%w(XOM))

    hits = run_screen("NATR > 1.738; NATR < 1.739;", %w(XOM), "2009-08-11")
    expect(hits).to match_array(%w(XOM))

    hits = run_screen("NATR50 > 2.076; NATR50 < 2.077;", %w(XOM), "2009-08-11")
    expect(hits).to match_array(%w(XOM))
  end

  it "Rate Of Change" do
    hits = run_screen("ROC12 = ROC;", %w(AAPL), "2015-03-02")
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("ROC20 > 10.18; ROC20 < 10.19;", %w(AAPL), "2015-03-02")
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("ROC50 > 20.92; ROC50 < 20.93;", %w(AAPL), "2015-03-02")
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("ROC20 < -2.941; ROC20 > -2.942;", %w(IKAN), "2015-03-02")
    expect(hits).to match_array(%w(IKAN))

    hits = run_screen("ROC50 > 3.12; ROC50 < 3.13;", %w(IKAN), "2015-03-02")
    expect(hits).to match_array(%w(IKAN))
  end

  it "Bollinger Bands" do
    hits = run_screen("BOLLINGER_UPPER = BOLLINGER_UPPER20,2; BOLLINGER_LOWER = BOLLINGER_LOWER20,2;", %w(XOM), "2013-12-31")
    expect(hits).to match_array(%w(XOM))

    hits = run_screen("BOLLINGER_UPPER = 135.102; BOLLINGER_LOWER = 116.125;", %w(AAPL), "2015-03-02")
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("BOLLINGER_UPPER = 572.97; BOLLINGER_LOWER = 545.865;", %w(AAPL), "2014-01-02")
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("BOLLINGER_UPPER50,2 = 712.389; BOLLINGER_LOWER50,2 = 605.522;", %w(AAPL), "2012-10-31")
    expect(hits).to match_array(%w(AAPL))

    hits = run_screen("BOLLINGER_UPPER20,2 = 1.33; BOLLINGER_LOWER20,2 = 1.135;", %w(IKAN), "2013-12-31")
    expect(hits).to match_array(%w(IKAN))

    hits = run_screen("BOLLINGER_UPPER50,2 = 1.396; BOLLINGER_LOWER50,2 = 1.081;", %w(IKAN), "2013-12-31")
    expect(hits).to match_array(%w(IKAN))
  end

  it "Arithmetic parameter lists" do
    hits = run_screen("ATR30 = ATR(15+15)", %w(AAPL XOM IKAN FLEX), "2015-01-02")
    expect(hits).to match_array(%w(AAPL XOM IKAN FLEX))

    hits = run_screen("ATR30 = ATR(10+10+10)", %w(AAPL XOM IKAN FLEX), "2015-01-02")
    expect(hits).to match_array(%w(AAPL XOM IKAN FLEX))

    hits = run_screen("ATR30 = ATR(15*2)", %w(AAPL XOM IKAN FLEX), "2015-01-02")
    expect(hits).to match_array(%w(AAPL XOM IKAN FLEX))

    hits = run_screen("ATR30 = ATR(10*3)", %w(AAPL XOM IKAN FLEX), "2015-01-02")
    expect(hits).to match_array(%w(AAPL XOM IKAN FLEX))

    hits = run_screen("ATR30 = ATR(5*6)", %w(AAPL XOM IKAN FLEX), "2015-01-02")
    expect(hits).to match_array(%w(AAPL XOM IKAN FLEX))

    hits = run_screen("ATR50 = ATR(15+15)", %w(AAPL XOM IKAN FLEX), "2015-01-02")
    expect(hits).to be_empty 

    hits = run_screen("ATR50 = ATR(10+10+10)", %w(AAPL XOM IKAN FLEX), "2015-01-02")
    expect(hits).to be_empty 

    hits = run_screen("ATR50 = ATR(15*2)", %w(AAPL XOM IKAN FLEX), "2015-01-02")
    expect(hits).to be_empty

    hits = run_screen("ATR50 = ATR(10*3)", %w(AAPL XOM IKAN FLEX), "2015-01-02")
    expect(hits).to be_empty 

    hits = run_screen("ATR50 = ATR(5*6)", %w(AAPL XOM IKAN FLEX), "2015-01-02")
    expect(hits).to be_empty
  end
end

RSpec.describe "Defect Tests" do
  it "splits should be on date less than or equal to" do
    hits = run_screen("C1 = 101.25; O1 = 98.5; H1 = 103.94;", %w(AAPL), "2000-06-21")
    expect(hits).to be_empty
  end

  it "should not crash on truncated ptab files" do
    hits = run_screen("C > 0;", %w(ABV-C), "2015-03-20")
    expect(hits).to be_empty
    expect($?).to eq(0)
  end

  it "should recognize OBV token with no conflicts" do
    hits = run_screen("OBV > 0;", %w(AAPL), "2015-03-20")
    expect(hits).to match_array(%w(AAPL))
    expect($?).to eq(0)
  end
end
