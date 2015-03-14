#! /bin/sh

cd ../

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
CAH
HSY
MCK
PPDI
"

./screen.pl -list TESTS/list7 -screen TESTS/tdsetup -date 2010-08-02
./screen.pl -list TESTS/list7 -screen TESTS/tdsetup -date 2010-08-02 -nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
CAH
HSY
MCK
PPDI
"

./screen.pl -list TESTS/list7 -screen TESTS/tdsetup2 -date 2010-08-02
./screen.pl -list TESTS/list7 -screen TESTS/tdsetup2 -date 2010-08-02 -nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4925.68 (return -1.49%)
QQQQ buy and hold: 26.46%
3 trades (1 wins / 2 losses)
Win ratio 33.33%
Average win 0.909% / 0.091 R
Average loss -8.307% / -0.831 R
Maximum drawdown 1.609%
System quality number -2.0
Ulcer Index 0.0157
Standard deviation of returns 0.427
Sharpe ratio -4.500
Recovery factor 0.926
Max adverse excursion 0.000%
Expectancy -5.2347% / -0.5234 R
"

./backtest.pl -tickers=ALJ -entry TESTS/tdsetup2 -exit TESTS/out -start 2006-09-05 -finish 2007-07-15 --skip-progress --skip-trades
./backtest.pl -tickers=ALJ -entry TESTS/tdsetup2 -exit TESTS/out -start 2006-09-05 -finish 2007-07-15 --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 5000 (return 0.00%)
QQQQ buy and hold: 8.17%
"

./backtest.pl -tickers=CLMT -entry TESTS/tdsetup2 -exit TESTS/out -start 2006-11-07 -finish 2007-05-18 --skip-progress
./backtest.pl -tickers=CLMT -entry TESTS/tdsetup2 -exit TESTS/out -start 2006-11-07 -finish 2007-05-18 --skip-progress --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4648.53 (return -7.03%)
Paid out 44.48 in dividends
QQQQ buy and hold: 25.95%
80 trades (20 wins / 59 losses)
Win ratio 25.00%
Average win 7.991% / 0.799 R
Average loss -5.617% / -0.561 R
Maximum drawdown 17.249%
System quality number -1.8
Ulcer Index 0.0878
Standard deviation of returns 3.223
Sharpe ratio -0.626
Recovery factor 0.408
Max adverse excursion 7.597%
Expectancy -2.2151% / -0.2212 R
"

time ./backtest.pl -list=TESTS/stock_universe.txt -entry TESTS/tdsetup2 -exit TESTS/out -start 2006-09-01 -finish 2007-09-15 --skip-progress --skip-trades
time ./backtest.pl -list=TESTS/stock_universe.txt -entry TESTS/tdsetup2 -exit TESTS/out -start 2006-09-01 -finish 2007-09-15 --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "Expecting:
AAME

AAME

AAME

AAME

got: "

./screen.pl --screen TESTS/guppy1 --ticker=AAME --date 2010-09-16 --nocache
./screen.pl --screen TESTS/guppy2 --ticker=AAME --date 2010-09-16 --nocache

./screen.pl --screen TESTS/guppy1 --ticker=AAME --date 2010-09-16
./screen.pl --screen TESTS/guppy2 --ticker=AAME --date 2010-09-16


echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "No Results! [test should terminate]"

./screen.pl -ticker=AAPL -date=2010-01-02 -screen TESTS/nosemi
