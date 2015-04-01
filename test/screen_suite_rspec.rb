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
	} 

def run_screen(screen, tickers, date)
  Dir.chdir("../ui/cmdline")
  cmdline = "./screen.rb -t #{tickers.join(',')} -d #{date} -c \"#{screen}\""
  output = `#{cmdline}`
  Dir.chdir(HOMEDIR)
  output.split 
end

RSpec.describe "Screener" do

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

RSpec.describe "Legacy Tests" do

  it "test #1" do

  end
end

RSpec.describe "Defect Tests" do
  it "splits should be on date less than or equal to" do
    hits = run_screen("C1 = 101.25; O1 = 98.5; H1 = 103.94;", %w(AAPL), "2000-06-21")
    expect(hits).to be_empty
  end
end