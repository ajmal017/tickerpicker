#! /bin/sh

cd ../

echo "
total: 5000 (return 0.00%)
QQQQ buy and hold: -0.90%
"

./backtest.pl -tickers=ALLT -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2006-12-09 --skip-progress 
./backtest.pl -tickers=ALLT -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2006-12-09 --skip-progress --nocache

echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo " 
total: 5174.55 (return 3.49%)
Paid out 1.84 in dividends
QQQQ buy and hold: -0.90%
"

./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2006-12-09 --skip-progress --skip-trades

./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2006-12-09 --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 3615.99 (return -27.68%)
Paid out 212.93 in dividends
QQQQ buy and hold: -1.49%
199 trades (46 wins / 153 losses)
Win ratio 23.12%
Average win 24.136% / 2.414 R
Average loss -9.422% / -0.942 R
Maximum drawdown 56.938%
System quality number -1.2
Ulcer Index 0.3293
Standard deviation of returns 22.370
Sharpe ratio -0.052
Recovery factor 0.486
Max adverse excursion 9.707%
Expectancy -1.6646% / -0.1666 R 
"

time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2009-12-09 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2009-12-09 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 2732.78393 (return -45.34%)
Paid out 116.56393 in dividends
QQQQ buy and hold: -32.10%
154 trades (19 wins / 132 losses)
Win ratio 12.34%
Average win 8.402% / 0.841 R
Average loss -7.099% / -0.710 R
Maximum drawdown 51.513%
System quality number -6.4
Ulcer Index 0.2084
Standard deviation of returns 13.088
Sharpe ratio -1.155
Recovery factor 0.880
Max adverse excursion 5.977%
Expectancy -5.1869% / -0.5186 R 
"

time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/200dayavg -exit TESTS/200dayout -start 2006-11-17 -finish 2008-12-09 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/200dayavg -exit TESTS/200dayout -start 2006-11-17 -finish 2008-12-09 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 5069.15 (return 1.38%)
Paid out 9.68 in dividends
QQQQ buy and hold: -0.90%
"

time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2006-11-17 -finish 2006-12-09 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2006-11-17 -finish 2006-12-09 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 5247.47 (return 4.95%)
Paid out 13.06 in dividends
QQQQ buy and hold: 9.42%
37 trades (16 wins / 20 losses)
Win ratio 43.24%
Average win 1.476% / 0.148 R
Average loss -3.055% / -0.306 R
Maximum drawdown 3.550%
System quality number -2.1
Ulcer Index 0.0149
Standard deviation of returns 3.191
Sharpe ratio 0.172
Recovery factor 1.394
Max adverse excursion 0.000%
Expectancy -1.0960% / -0.1097 R 
"

time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/20dayavg-checks -exit TESTS/200dayout -start 2006-09-17 -finish 2006-12-09 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/20dayavg-checks -exit TESTS/200dayout -start 2006-09-17 -finish 2006-12-09 --skip-progress --skip-trades --nocache
