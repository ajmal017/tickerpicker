#! /bin/sh

cd ../

echo "
ACOR	12	2010-04-16	38.56	(open)		 

total: 4983.56 (return -0.33%)
QQQQ buy and hold: -1.26%
"

./backtest.pl -tickers ACOR -entry TESTS/in2 -exit TESTS/out -start 2010-04-15 -finish 2010-04-20 --skip-progress
./backtest.pl -tickers ACOR -entry TESTS/in2 -exit TESTS/out -start 2010-04-15 -finish 2010-04-20 --skip-progress  --nocache

echo "";
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++";
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++";
echo "
ACOR	25	2006-11-21	19.35	2006-12-08	16.73	-13.540% 

total: 4934.50 (return -1.31%)
QQQQ buy and hold: -0.90%
1 trades (0 wins / 1 losses)
Win ratio 0.00%
Average win 0.000% / 0.000 R
Average loss -13.540% / -1.358 R
Maximum drawdown 1.674%
System quality number 0.0
Ulcer Index 0.0071
Standard deviation of returns 0.175
Sharpe ratio -3.909
Recovery factor 0.783
Max adverse excursion 0.000%
Expectancy -13.5401% / -1.3575 R
"

./backtest.pl -tickers=ACOR list -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2006-12-09 --skip-progress  
./backtest.pl -tickers=ACOR list -entry TESTS/in2 -exit TESTS/out -start 2006-11-17 -finish 2006-12-09 --skip-progress --nocache

echo "";
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++";
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++";

echo "
total: 5832.03 (return 16.64%)
Paid out 57.70 in dividends
QQQQ buy and hold: 17.44%
207 trades (49 wins / 154 losses)
Win ratio 23.67%
Average win 17.942% / 1.803 R
Average loss -8.666% / -0.872 R
Maximum drawdown 45.490%
System quality number -2.1
Ulcer Index 0.1780
Standard deviation of returns 11.547
Sharpe ratio 0.089
Recovery factor 0.366
Max adverse excursion 9.722%
Expectancy -2.3676% / -0.2390 R 
";

time ./backtest.pl -list TESTS/list4 -entry TESTS/in1 -exit TESTS/out -start 2006-02-01 -finish 2010-04-20 --skip-progress --skip-trades
time ./backtest.pl -list TESTS/list4 -entry TESTS/in1 -exit TESTS/out -start 2006-02-01 -finish 2010-04-20 --skip-progress --skip-trades --nocache


echo "";
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++";
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++";
echo "
total: 4999.32 (return -0.01%)
QQQQ buy and hold: 18.82%
16 trades (4 wins / 12 losses)
Win ratio 25.00%
Average win 17.612% / 1.760 R
Average loss -9.846% / -0.985 R
Maximum drawdown 8.709%
System quality number -0.9
Ulcer Index 0.0492
Standard deviation of returns 2.043
Sharpe ratio -1.381
Recovery factor 0.001
Max adverse excursion 7.589%
Expectancy -2.9813% / -0.2987 R
";

time ./backtest.pl -tickers=ACOR list -entry TESTS/in2 -exit TESTS/out -start 2006-04-15 -finish 2010-04-20 --skip-progress --skip-trades
time ./backtest.pl -tickers=ACOR list -entry TESTS/in2 -exit TESTS/out -start 2006-04-15 -finish 2010-04-20 --skip-progress --skip-trades --nocache
