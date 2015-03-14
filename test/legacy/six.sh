#! /bin/sh

cd ../

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4952.48 (return -0.95%)
QQQQ buy and hold: 19.68%
2 trades (1 wins / 1 losses)
Win ratio 50.00%
Average win 3.333% / 0.333 R
Average loss -12.899% / -1.290 R
Maximum drawdown 1.306%
System quality number -0.8
Ulcer Index 0.0122
Standard deviation of returns 0.421
Sharpe ratio -3.177
Recovery factor 0.727
Max adverse excursion 0.000%
Expectancy -4.7826% / -0.4783 R
"

./backtest.pl -ticker=AACC -start 2009-10-01 -finish 2010-10-01 -entry TESTS/bcontentry -exit TESTS/bcontexit --skip-progress --skip-trades
./backtest.pl -ticker=AACC -start 2009-10-01 -finish 2010-10-01 -entry TESTS/bcontentry -exit TESTS/bcontexit --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 5011.96 (return 0.24%)
QQQQ buy and hold: 1.66%
1 trades (1 wins / 0 losses)
Win ratio 100.00%
Average win 2.410% / 0.241 R
Average loss 0.000% / 0.000 R
Maximum drawdown 0.000%
System quality number 0.0
Ulcer Index 0.0000
Standard deviation of returns 0.120
Sharpe ratio -2.911
Recovery factor 
Max adverse excursion 0.000%
Expectancy 2.4096% / 0.2407 R
"

./backtest.pl -ticker=AZPN -start 2010-07-29 -finish 2010-08-04 -entry TESTS/bcontentry -exit TESTS/bcontexit --skip-progress --skip-trades
./backtest.pl -ticker=AZPN -start 2010-07-29 -finish 2010-08-04 -entry TESTS/bcontentry -exit TESTS/bcontexit --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 5132.396595 (return 2.65%)
QQQQ buy and hold: 19.68%
6 trades (3 wins / 3 losses)
Win ratio 50.00%
Average win 18.304% / 1.830 R
Average loss -9.224% / -0.925 R
Maximum drawdown 2.877%
System quality number 0.6
Ulcer Index 0.0145
Standard deviation of returns 2.110
Sharpe ratio 0.885
Recovery factor 0.921
Max adverse excursion 2.377%
Expectancy 4.5402% / 0.4525 R
"

./backtest.pl -ticker=ABCB -start 2009-10-01 -finish 2010-10-01 -entry TESTS/bcontentry -exit TESTS/bcontexit --skip-progress --skip-trades
./backtest.pl -ticker=ABCB -start 2009-10-01 -finish 2010-10-01 -entry TESTS/bcontentry -exit TESTS/bcontexit --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4995.5 (return -0.09%)
QQQQ buy and hold: -2.28%
1 trades (0 wins / 1 losses)
Win ratio 0.00%
Average win 0.000% / 0.000 R
Average loss -0.909% / -0.091 R
Maximum drawdown 0.126%
System quality number 0.0
Ulcer Index 0.0009
Standard deviation of returns 0.045
Sharpe ratio -12.711
Recovery factor 0.714
Max adverse excursion 0.000%
Expectancy -0.9091% / -0.0909 R
"

./backtest.pl -ticker=ACCL -start 2009-10-29 -finish 2009-11-03 -entry TESTS/bcontentry -exit TESTS/bcontexit --skip-progress --skip-trades
./backtest.pl -ticker=ACCL -start 2009-10-29 -finish 2009-11-03 -entry TESTS/bcontentry -exit TESTS/bcontexit --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4990.31 (return -0.19%)
QQQQ buy and hold: -2.24%
1 trades (0 wins / 1 losses)
Win ratio 0.00%
Average win 0.000% / 0.000 R
Average loss -1.982% / -0.198 R
Maximum drawdown 0.194%
System quality number 0.0
Ulcer Index 0.0016
Standard deviation of returns 0.000
Sharpe ratio 0.000
Recovery factor 0.980
Max adverse excursion 0.000%
Expectancy -1.9821% / -0.1984 R
"

./backtest.pl -tickers=ABCO -start 2009-10-22 -finish 2009-10-28 -entry TESTS/binventry -exit TESTS/binvexit --skip-progress --skip-trades
./backtest.pl -tickers=ABCO -start 2009-10-22 -finish 2009-10-28 -entry TESTS/binventry -exit TESTS/binvexit --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 5184.98 (return 3.70%)
Paid out 26.28 in dividends
QQQQ buy and hold: 7.68%
24 trades (8 wins / 16 losses)
Win ratio 33.33%
Average win 24.285% / 2.428 R
Average loss -10.001% / -1.000 R
Maximum drawdown 9.345%
System quality number 0.4
Ulcer Index 0.0316
Standard deviation of returns 2.342
Sharpe ratio -0.709
Recovery factor 0.396
Max adverse excursion 7.973%
Expectancy 1.4275% / 0.1426 R
"

./backtest.pl -tickers=ADTN list -entry TESTS/bol_dayago1 -exit TESTS/tdout -start 2006-04-15 -finish 2010-08-20 --skip-progress --skip-trades
./backtest.pl -tickers=ADTN list -entry TESTS/bol_dayago1 -exit TESTS/tdout -start 2006-04-15 -finish 2010-08-20 --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 5733.32 (return 14.67%)
QQQQ buy and hold: 7.68%
29 trades (11 wins / 18 losses)
Win ratio 37.93%
Average win 24.700% / 2.470 R
Average loss -6.668% / -0.667 R
Maximum drawdown 6.292%
System quality number 1.3
Ulcer Index 0.0226
Standard deviation of returns 4.913
Sharpe ratio 1.277
Recovery factor 2.331
Max adverse excursion 6.549%
Expectancy 5.2303% / 0.5231 R
"

./backtest.pl -tickers=AAPL list -entry TESTS/bol_dayago2 -exit TESTS/out -start 2006-04-15 -finish 2010-08-20 --skip-progress --skip-trades
./backtest.pl -tickers=AAPL list -entry TESTS/bol_dayago2 -exit TESTS/out -start 2006-04-15 -finish 2010-08-20 --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 3858.71 (return -22.83%)
Paid out 16.69 in dividends
QQQQ buy and hold: -22.06%
347 trades (120 wins / 226 losses)
Win ratio 34.58%
Average win 8.583% / 0.859 R
Average loss -5.660% / -0.566 R
Maximum drawdown 46.980%
System quality number -1.3
Ulcer Index 0.2759
Standard deviation of returns 16.202
Sharpe ratio -1.389
Recovery factor 0.486
Max adverse excursion 9.556%
Expectancy -0.7342% / -0.0733 R 
"

./backtest.pl --entry TESTS/macd_in --exit TESTS/macd_out --start 2007-11-01 --finish 2009-10-30 --list TESTS/n100.txt --skip-trades --skip-progress
./backtest.pl --entry TESTS/macd_in --exit TESTS/macd_out --start 2007-11-01 --finish 2009-10-30 --list TESTS/n100.txt --skip-trades --skip-progress --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 5132.396595 (return 2.65%)
QQQQ buy and hold: 65.00%
6 trades (3 wins / 3 losses)
Win ratio 50.00%
Average win 18.304% / 1.830 R
Average loss -9.224% / -0.925 R
Maximum drawdown 2.877%
System quality number 0.6
Ulcer Index 0.0110
Standard deviation of returns 1.936
Sharpe ratio 0.442
Recovery factor 0.921
Max adverse excursion 2.377%
Expectancy 4.5402% / 0.4525 R
"

./backtest.pl --ticker=ABCB --start 2009-01-01 --finish 2010-10-01 --entry TESTS/bcontentry --exit TESTS/bcontexit --skip-trades --skip-progress
./backtest.pl --ticker=ABCB --start 2009-01-01 --finish 2010-10-01 --entry TESTS/bcontentry --exit TESTS/bcontexit --skip-trades --skip-progress --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 10065.06 (return 101.30%)
QQQQ buy and hold: -77.22%
57 trades (26 wins / 29 losses)
Win ratio 45.61%
Average win 35.139% / 3.519 R
Average loss -5.595% / -0.560 R
Maximum drawdown 9.887%
System quality number 1.9
Ulcer Index 0.0293
Standard deviation of returns 36.089
Sharpe ratio 0.788
Recovery factor 10.246
Max adverse excursion 9.600%
Expectancy 12.9855% / 1.3008 R
"

./backtest.pl --ticker=HANS --start=2000-01-01 --finish=2007-01-01  -entry TESTS/strength --exit TESTS/out --skip-progress --skip-trades
./backtest.pl --ticker=HANS --start=2000-01-01 --finish=2007-01-01  -entry TESTS/strength --exit TESTS/out --skip-progress --skip-trades --nocache
