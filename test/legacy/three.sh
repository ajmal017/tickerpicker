#! /bin/sh

cd ../

echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 4957.83 (return -0.84%)
QQQQ buy and hold: 3.00%
2 trades (0 wins / 2 losses)
Win ratio 0.00%
Average win 0.000% / 0.000 R
Average loss -4.545% / -0.454 R
Maximum drawdown 0.903%
System quality number -2.1
Ulcer Index 0.0052
Standard deviation of returns 0.322
Sharpe ratio -2.846
Recovery factor 0.930
Max adverse excursion 0.000%
Expectancy -4.5448% / -0.4544 R
"

time ./backtest.pl -tickers=ACAP -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-08-09 -finish 2007-09-07 --skip-progress --skip-trades
time ./backtest.pl -tickers=ACAP -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-08-09 -finish 2007-09-07 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 4923.87 (return -1.52%)
QQQQ buy and hold: -1.35%
4 trades (0 wins / 4 losses)
Win ratio 0.00%
Average win 0.000% / 0.000 R
Average loss -4.032% / -0.403 R
Maximum drawdown 1.583%
System quality number -3.1
Ulcer Index 0.0091
Standard deviation of returns 0.540
Sharpe ratio -2.456
Recovery factor 0.960
Max adverse excursion 0.000%
Expectancy -4.0315% / -0.4031 R
"

time  ./backtest.pl -tickers=ACAP -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-07-09 -finish 2007-09-09 --skip-progress --skip-trades
time  ./backtest.pl -tickers=ACAP -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-07-09 -finish 2007-09-09 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 5031.13 (return 0.62%)
Paid out 102.52 in dividends
QQQQ buy and hold: 18.13%
43 trades (8 wins / 35 losses)
Win ratio 18.60%
Average win 3.970% / 0.397 R
Average loss -8.021% / -0.802 R
Maximum drawdown 14.652%
System quality number -3.0
Ulcer Index 0.0915
Standard deviation of returns 3.237
Sharpe ratio -2.132
Recovery factor 0.042
Max adverse excursion 4.630%
Expectancy -5.7899% / -0.5788 R 
"

time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2006-11-17 -finish 2007-12-09 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2006-11-17 -finish 2007-12-09 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++++++++++++";
echo "
total: 4616.91 (return -7.66%)
Paid out 66.15 in dividends
QQQQ buy and hold: -1.35%
19 trades (0 wins / 19 losses)
Win ratio 0.00%
Average win 0.000% / 0.000 R
Average loss -6.203% / -0.620 R
Maximum drawdown 9.049%
System quality number -7.0
Ulcer Index 0.0525
Standard deviation of returns 2.728
Sharpe ratio -1.880
Recovery factor 0.847
Max adverse excursion 0.000%
Expectancy -6.2029% / -0.6203 R 
"

time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-07-09 -finish 2007-09-09 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/stock_universe.txt -entry TESTS/200dayavg-byfive -exit TESTS/200dayout -start 2007-07-09 -finish 2007-09-09 --skip-progress --skip-trades --nocache
