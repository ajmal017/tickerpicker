#! /bin/sh

cd ../
echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "PLUG"

./screen.pl --screen TESTS/bigmovers --list TESTS/gaplist1.txt --date=2014-06-25
./screen.pl --screen TESTS/bigmovers --list TESTS/gaplist1.txt --date=2014-06-25 --nocache

echo "
+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4087.36 (return -18.25%)
QQQQ buy and hold: -100.00%
86 trades (23 wins / 50 losses)
Win ratio 26.74%
Average win 10.082% / 1.006 R
Average loss -8.484% / -0.846 R
Maximum drawdown 36.045%
System quality number -3.4
Ulcer Index 0.2002
Standard deviation of returns 9.636
Sharpe ratio 0.232
Recovery factor 0.506
Max adverse excursion 0.000%
Expectancy -3.5189% / -0.3509 R
"

time ./backtest.pl -skip-progress -list TESTS/gaplist2.txt -start 1991-10-01 -finish 1996-11-15 -short-entry TESTS/261550 -short-exit TESTS/301156 -short-trail TESTS/335091 --skip-trades
time ./backtest.pl -skip-progress -list TESTS/gaplist2.txt -start 1991-10-01 -finish 1996-11-15 -short-entry TESTS/261550 -short-exit TESTS/301156 -short-trail TESTS/335091 --skip-trades --nocache
echo ""



echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 19731.51 (return 294.63%)
Margin calls: 1825.67226
QQQQ buy and hold: -100.00%
47 trades (19 wins / 23 losses)
Win ratio 40.43%
Average win 8.322% / 0.829 R
Average loss -5.416% / -0.540 R
Maximum drawdown 46.232%
System quality number 0.1
Ulcer Index 0.1751
Standard deviation of returns 164.011
Sharpe ratio 2.380
Recovery factor 6.373
Max adverse excursion 0.000%
Expectancy 0.1377% / 0.0135 R
"

./backtest.pl -skip-progress -list TESTS/stock_universe.txt -start 1992-05-01 -finish 1992-09-01 -short-entry TESTS/261550 -short-exit TESTS/301156 -short-trail TESTS/335091 --skip-trades
./backtest.pl -skip-progress -list TESTS/stock_universe.txt -start 1992-05-01 -finish 1992-09-01 -short-entry TESTS/261550 -short-exit TESTS/301156 -short-trail TESTS/335091 --skip-trades --nocache

