#! /bin/sh

cd ../

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 3929.56 (return -21.41%)
Paid out 2.07 in dividends
QQQQ buy and hold: -28.40%
342 trades (57 wins / 202 losses)
Win ratio 16.67%
Average win 14.317% / 1.436 R
Average loss -5.349% / -0.538 R
Maximum drawdown 34.237%
System quality number -4.1
Ulcer Index 0.1549
Standard deviation of returns 9.144
Sharpe ratio -0.299
Recovery factor 0.625
Max adverse excursion 9.639%
Expectancy -2.0710% / -0.2091 R 
"

time ./backtest.pl -start 2008-03-15 -finish 2009-03-19 -list TESTS/short-t.txt -entry TESTS/306873 -exit TESTS/909050 -filter TESTS/166156 -trail TESTS/550138 --skip-trades --skip-progress
time ./backtest.pl -start 2008-03-15 -finish 2009-03-19 -list TESTS/short-t.txt -entry TESTS/306873 -exit TESTS/909050 -filter TESTS/166156 -trail TESTS/550138 --skip-trades --skip-progress --nocache


echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4979 (return -0.42%)
QQQQ buy and hold: 14.39%
4 trades (0 wins / 1 losses)
Win ratio 0.00%
Average win 0.000% / 0.000 R
Average loss -2.074% / -0.209 R
Maximum drawdown 0.420%
System quality number -4.6
Ulcer Index 0.0012
Standard deviation of returns 0.000
Sharpe ratio 0.000
Recovery factor 1.000
Max adverse excursion 0.000%
Expectancy -2.0741% / -0.2090 R
"

./backtest.pl -start 2008-03-31 -finish 2008-06-01 -tickers ADGF -entry TESTS/306873 -exit TESTS/909050 -filter TESTS/166156 -trail TESTS/550138 --skip-progress --skip-trades
./backtest.pl -start 2008-03-31 -finish 2008-06-01 -tickers ADGF -entry TESTS/306873 -exit TESTS/909050 -filter TESTS/166156 -trail TESTS/550138 --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4946 (return -1.08%)
QQQQ buy and hold: 5.49%
11 trades (1 wins / 4 losses)
Win ratio 9.09%
Average win 1.344% / 0.135 R
Average loss -3.060% / -0.306 R
Maximum drawdown 1.775%
System quality number -5.2
Ulcer Index 0.0109
Standard deviation of returns 0.514
Sharpe ratio -2.014
Recovery factor 0.608
Max adverse excursion 0.192%
Expectancy -2.6594% / -0.2660 R
"

./backtest.pl -start 2008-03-31 -finish 2008-09-01 -tickers ADGF -entry TESTS/306873 -exit TESTS/909050 -trail TESTS/550138 --skip-progress --skip-trades
./backtest.pl -start 2008-03-31 -finish 2008-09-01 -tickers ADGF -entry TESTS/306873 -exit TESTS/909050 -trail TESTS/550138 --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo " 
total: 4976.96 (return -0.46%)
QQQQ buy and hold: 5.40%
1 trades (0 wins / 1 losses)
Win ratio 0.00%
Average win 0.000% / 0.000 R
Average loss -4.624% / -0.462 R
Maximum drawdown 0.461%
System quality number 0.0
Ulcer Index 0.0037
Standard deviation of returns 0.000
Sharpe ratio 0.000
Recovery factor 0.998
Max adverse excursion 0.000%
Expectancy -4.6243% / -0.4615 R
"

./backtest.pl -start 2008-03-15 -finish 2008-04-01 -tickers ABVA -entry TESTS/306873 -exit TESTS/909050 -filter TESTS/166156 -trail TESTS/550138 --skip-progress
./backtest.pl -start 2008-03-15 -finish 2008-04-01 -tickers ABVA -entry TESTS/306873 -exit TESTS/909050 -filter TESTS/166156 -trail TESTS/550138 --skip-progress --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo " 
total: 5000 (return 0.00%)
QQQQ buy and hold: -100.00%
"

./backtest.pl -skip-progress -list TESTS/stock_universe.txt -start 1998-07-06 -finish 2000-02-04 -entry TESTS/361437 -exit TESTS/604929 -filter TESTS/811740 -trail TESTS/671281 --skip-progress
./backtest.pl -skip-progress -list TESTS/stock_universe.txt -start 1998-07-06 -finish 2000-02-04 -entry TESTS/361437 -exit TESTS/604929 -filter TESTS/811740 -trail TESTS/671281 --skip-progress --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo " 
total: 24680.19 (return 393.60%)
Margin calls: 36510.4749233333
QQQQ buy and hold: -100.00%
752 trades (196 wins / 387 losses)
Win ratio 26.06%
Average win 9.135% / 0.912 R
Average loss -7.478% / -0.747 R
Maximum drawdown 86.451%
System quality number -10.3
Ulcer Index 0.5194
Standard deviation of returns 179.633
Sharpe ratio 1.697
Recovery factor 4.553
Max adverse excursion 0.000%
Expectancy -3.1481% / -0.3143 R
"

time ./backtest.pl -skip-progress -list TESTS/stock_universe.txt -start 1991-10-01 -finish 1996-11-15 -short-entry TESTS/261550 -short-exit TESTS/301156 -short-trail TESTS/335091 --skip-trades
time ./backtest.pl -skip-progress -list TESTS/stock_universe.txt -start 1991-10-01 -finish 1996-11-15 -short-entry TESTS/261550 -short-exit TESTS/301156 -short-trail TESTS/335091 --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo " 
FISI
"

./screen.pl -nocache -tickers FISI,WMG -screen TESTS/425803 -date 2011-02-01
./screen.pl -nocache -tickers FISI,WMG -screen TESTS/746722 -date 2011-02-01

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo " 
total: 5381.7 (return 7.63%)
QQQQ buy and hold: -100.00%
43 trades (12 wins / 21 losses)
Win ratio 27.91%
Average win 20.946% / 2.090 R
Average loss -9.147% / -0.901 R
Maximum drawdown 9.077%
System quality number -0.2
Ulcer Index 0.0217
Standard deviation of returns 3.377
Sharpe ratio 0.326
Recovery factor 0.841
Max adverse excursion 0.000%
Expectancy -0.7488% / -0.0665 R 
"

./backtest.pl -skip-progress -tickers TDSC -start 1991-12-12 -finish 1994-03-21 -entry TESTS/867213 -exit TESTS/190780 -trail TESTS/213106 --skip-trades
./backtest.pl -skip-progress -tickers TDSC -start 1991-12-12 -finish 1994-03-21 -entry TESTS/867213 -exit TESTS/190780 -trail TESTS/213106 --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 5082.5 (return 1.65%)
QQQQ buy and hold: -100.00%
1 trades (1 wins / 0 losses)
Win ratio 100.00%
Average win 16.923% / 1.687 R
Average loss 0.000% / 0.000 R
Maximum drawdown 0.441%
System quality number 0.0
Ulcer Index 0.0015
Standard deviation of returns 0.812
Sharpe ratio 0.232
Recovery factor 3.744
Max adverse excursion 0.000%
Expectancy 16.9231% / 1.6871 R
"

./backtest.pl -skip-progress -tickers ACMR -start 1998-02-22 -finish 1998-04-20 -entry TESTS/147952 -exit TESTS/861886 --skip-trades
./backtest.pl -skip-progress -tickers ACMR -start 1998-02-22 -finish 1998-04-20 -entry TESTS/147952 -exit TESTS/861886 --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "[should run]"

./screen.pl --list TESTS/stock_universe.txt --screen TESTS/206681 --date 2008-01-01 | wc

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4171.61 (return -16.57%)
Paid out 3.29 in dividends
QQQQ buy and hold: -34.45%
57 trades (12 wins / 45 losses)
Win ratio 21.05%
Average win 30.897% / 2.059 R
Average loss -12.110% / -0.807 R
Maximum drawdown 41.865%
System quality number -0.9
Ulcer Index 0.2344
Standard deviation of returns 13.277
Sharpe ratio 0.356
Recovery factor 0.396
Max adverse excursion 9.720%
Expectancy -3.0560% / -0.2040 R 
"

./backtest.pl -skip-progress -start 2008-01-28 -finish 2009-01-31 -list TESTS/stock_universe.txt -entry TESTS/501389 -exit TESTS/256814 -filter TESTS/543504 -stop TESTS/882547 -trail TESTS/827431 --skip-trades
./backtest.pl -skip-progress -start 2008-01-28 -finish 2009-01-31 -list TESTS/stock_universe.txt -entry TESTS/501389 -exit TESTS/256814 -filter TESTS/543504 -stop TESTS/882547 -trail TESTS/827431 --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4927.28 (return -1.45%)
QQQQ buy and hold: -0.39%
1 trades (0 wins / 1 losses)
Win ratio 0.00%
Average win 0.000% / 0.000 R
Average loss -14.991% / -1.000 R
Maximum drawdown 1.454%
System quality number 0.0
Ulcer Index 0.0120
Standard deviation of returns 0.000
Sharpe ratio 0.000
Recovery factor 0.997
Max adverse excursion 0.000%
Expectancy -14.9907% / -1.0000 R
"

./backtest.pl -skip-progress -skip-trades -start 2008-05-20 -finish 2008-05-28 -tickers BWEN -entry TESTS/501389 -exit TESTS/256814 -filter TESTS/543504 -stop TESTS/882547 -trail TESTS/827431
./backtest.pl -skip-progress -skip-trades -start 2008-05-20 -finish 2008-05-28 -tickers BWEN -entry TESTS/501389 -exit TESTS/256814 -filter TESTS/543504 -stop TESTS/882547 -trail TESTS/827431 --nocache
