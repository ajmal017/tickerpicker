#! /bin/sh

cd ../

echo "No Results"
./screen.pl --tickers AIG,CDE,FNSR --screen TESTS/six --date 2009-10-01

echo "
+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "No Results"

./screen.pl -date 2011-05-12 --tickers SPEX -screen TESTS/six


echo "
+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4716.97 (return -5.66%)
Paid out 23.40 in dividends
QQQQ buy and hold: -19.70%
277 trades (138 wins / 125 losses)
Win ratio 49.82%
Average win 6.324% / 0.634 R
Average loss -7.340% / -0.735 R
Maximum drawdown 21.546%
System quality number -1.0
Ulcer Index 0.1068
Standard deviation of returns 5.607
Sharpe ratio -1.777
Recovery factor 0.263
Max adverse excursion 9.742%
Expectancy -0.5325% / -0.0528 R 
"

./backtest.pl -start 2008-03-15 -finish 2009-04-20 -list TESTS/short-t.txt -entry TESTS/noleadingzero -exit TESTS/909050 -filter TESTS/166156 -trail TESTS/550138 --skip-trades --skip-progress
./backtest.pl -start 2008-03-15 -finish 2009-04-20 -list TESTS/short-t.txt -entry TESTS/noleadingzero -exit TESTS/909050 -filter TESTS/166156 -trail TESTS/550138 --skip-trades --skip-progress --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4840.06 (return -3.20%)
QQQQ buy and hold: 24.28%
12 trades (2 wins / 9 losses)
Win ratio 16.67%
Average win 46.610% / 3.140 R
Average loss -13.401% / -0.901 R
Maximum drawdown 11.869%
System quality number -0.5
Ulcer Index 0.0689
Standard deviation of returns 4.087
Sharpe ratio -1.358
Recovery factor 0.270
Max adverse excursion 87.684%
Expectancy -3.3991% / -0.2273 R
"

./backtest.pl -start 2009-05-02 -finish 2009-12-01 --tickers AIG,CDE,FNSR -entry TESTS/883112 -exit TESTS/525880 -filter TESTS/667330 -stop TESTS/636502 --skip-trades --skip-progress
./backtest.pl -start 2009-05-02 -finish 2009-12-01 --tickers AIG,CDE,FNSR -entry TESTS/883112 -exit TESTS/525880 -filter TESTS/667330 -stop TESTS/636502 --skip-trades --skip-progress --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 5119.59625 (return 2.39%)
QQQQ buy and hold: 24.28%
3 trades (1 wins / 1 losses)
Win ratio 33.33%
Average win 48.897% / 3.325 R
Average loss -24.096% / -1.667 R
Maximum drawdown 4.229%
System quality number -0.0
Ulcer Index 0.0250
Standard deviation of returns 2.279
Sharpe ratio 0.031
Recovery factor 0.565
Max adverse excursion 87.684%
Expectancy 0.2348% / -0.0028 R
"

./backtest.pl -start 2009-05-02 -finish 2009-12-01 --tickers FNSR -entry TESTS/883112 -exit TESTS/525880 -filter TESTS/667330 -stop TESTS/636502 --skip-trades --skip-progress
./backtest.pl -start 2009-05-02 -finish 2009-12-01 --tickers FNSR -entry TESTS/883112 -exit TESTS/525880 -filter TESTS/667330 -stop TESTS/636502 --skip-trades --skip-progress --nocache


echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 5426.59 (return 8.53%)
Paid out 100.73 in dividends
QQQQ buy and hold: 26.75%
97 trades (27 wins / 69 losses)
Win ratio 27.84%
Average win 14.589% / 1.455 R
Average loss -6.485% / -0.649 R
Maximum drawdown 19.628%
System quality number -0.4
Ulcer Index 0.1138
Standard deviation of returns 5.778
Sharpe ratio 1.143
Recovery factor 0.435
Max adverse excursion 6.892%
Expectancy -0.6192% / -0.0634 R 
"

time ./backtest.pl --list TESTS/strength_list.txt --start=2006-01-01 --finish=2008-01-01  -entry TESTS/strength --exit TESTS/out --skip-progress --skip-trades
time ./backtest.pl --list TESTS/strength_list.txt --start=2006-01-01 --finish=2008-01-01  -entry TESTS/strength --exit TESTS/out --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4183.04 (return -16.34%)
QQQQ buy and hold: 18.76%
39 trades (6 wins / 32 losses)
Win ratio 15.38%
Average win 4.232% / 0.427 R
Average loss -6.662% / -0.665 R
Maximum drawdown 18.927%
System quality number -5.8
Ulcer Index 0.0688
Standard deviation of returns 3.775
Sharpe ratio -0.987
Recovery factor 0.863
Max adverse excursion 2.778%
Expectancy -4.9863% / -0.4969 R 
"

./backtest.pl --list TESTS/strength_list2.txt --start=2007-03-01 --finish=2008-01-01  -entry TESTS/strength --exit TESTS/out --skip-progress --skip-trades
./backtest.pl --list TESTS/strength_list2.txt --start=2007-03-01 --finish=2008-01-01  -entry TESTS/strength --exit TESTS/out --skip-progress --skip-trades --nocache

echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 4990.99 (return -0.18%)
QQQQ buy and hold: 3.06%
2 trades (0 wins / 2 losses)
Win ratio 0.00%
Average win 0.000% / 0.000 R
Average loss -7.560% / -0.767 R
Maximum drawdown 0.978%
System quality number -4.6
Ulcer Index 0.0057
Standard deviation of returns 0.160
Sharpe ratio -4.915
Recovery factor 0.184
Max adverse excursion 0.000%
Expectancy -7.5598% / -0.7667 R 
"

./backtest.pl --list TESTS/strength_list2.txt --start=2007-03-01 --finish=2007-04-10  -entry TESTS/strength --exit TESTS/out --skip-progress --skip-trades
./backtest.pl --list TESTS/strength_list2.txt --start=2007-03-01 --finish=2007-04-10  -entry TESTS/strength --exit TESTS/out --skip-progress --skip-trades --nocache


echo "+++++++++++++++++++++++++";
echo "+++++++++++++++++++++++++";
echo "
total: 5044.72 (return 0.89%)
QQQQ buy and hold: 8.02%
4 trades (1 wins / 3 losses)
Win ratio 25.00%
Average win 6.339% / 0.633 R
Average loss -5.088% / -0.516 R
Maximum drawdown 0.993%
System quality number -0.8
Ulcer Index 0.0054
Standard deviation of returns 0.285
Sharpe ratio -1.759
Recovery factor 0.896
Max adverse excursion 0.818%
Expectancy -2.2314% / -0.2288 R 
"

./backtest.pl --list TESTS/strength_list2.txt --start=2007-03-01 --finish=2007-05-04  -entry TESTS/strength --exit TESTS/out --skip-progress --skip-trades 
./backtest.pl --list TESTS/strength_list2.txt --start=2007-03-01 --finish=2007-05-04  -entry TESTS/strength --exit TESTS/out --skip-progress --skip-trades --nocache 
