CC=g++
TAFLAGS= -I /usr/local/include/ta-lib/ -L/usr/local/lib64/ -lta_lib
CFLAGS= -I data -I indicators -I core -I backtest

app: screen.o btest.o indicator data core backtest
	$(CC) $(TAFLAGS) ./data/*.o ./indicators/*.o ./core/*.o screen.o -o screen.bin 
	$(CC) $(TAFLAGS) ./data/*.o ./indicators/*.o ./core/*.o ./backtest/*.o btest.o -o btest.bin 

indicator: indicators/indicators.o indicators/lookbacks.o indicators/tables.o indicators/math.o indicators/metrics.o

data: data/date.o data/pdata.o data/ptable.o

core: core/ruleset.o core/screen.o core/stock.o

backtest: backtest/strategy.o backtest/portfolio.o backtest/position.o backtest/config.o backtest/archive.o

btest.o : btest.cpp
	$(CC) $(CFLAGS) $(TAFLAGS) -c -o btest.o btest.cpp

screen.o : screen.cpp
	$(CC) $(CFLAGS) $(TAFLAGS) -c -o screen.o screen.cpp

backtest/archive.o : backtest/archive.cpp
	$(CC) $(CFLAGS) -c -o ./backtest/archive.o backtest/archive.cpp

backtest/position.o : backtest/position.cpp
	$(CC) $(CFLAGS) -c -o ./backtest/position.o backtest/position.cpp

backtest/strategy.o : backtest/strategy.cpp
	$(CC) $(CFLAGS) -c -o ./backtest/strategy.o backtest/strategy.cpp

backtest/portfolio.o : backtest/portfolio.cpp
	$(CC) $(CFLAGS) -c -o ./backtest/portfolio.o backtest/portfolio.cpp

backtest/config.o : backtest/config.cpp
	$(CC) $(CFLAGS) -c -o ./backtest/config.o backtest/config.cpp

indicators/indicators.o: indicators/indicators.cpp
	$(CC) $(CFLAGS) $(TAFLAGS) -c -o ./indicators/indicators.o indicators/indicators.cpp

indicators/lookbacks.o: indicators/lookbacks.cpp
	$(CC) $(CFLAGS) $(TAFLAGS) -c -o ./indicators/lookbacks.o indicators/lookbacks.cpp

indicators/tables.o: indicators/tables.cpp
	$(CC) $(CFLAGS) -c -o ./indicators/tables.o indicators/tables.cpp

indicators/math.o: indicators/math.cpp
	$(CC) $(CFLAGS) -c -o ./indicators/math.o indicators/math.cpp

indicators/metrics.o: indicators/metrics.cpp
	$(CC) $(CFLAGS) $(TAFLAGS) -c -o ./indicators/metrics.o indicators/metrics.cpp

data/date.o: data/date.cpp data/date.h
	$(CC) $(CFLAGS) -c -o ./data/date.o data/date.cpp

data/pdata.o: data/pdata.cpp data/pdata.h
	$(CC) $(CFLAGS) -c -o ./data/pdata.o data/pdata.cpp

data/ptable.o: data/ptable.cpp data/ptable.h
	$(CC) $(CFLAGS) -c -o ./data/ptable.o data/ptable.cpp

core/ruleset.o: core/ruleset.cpp core/ruleset.h
	$(CC) $(CFLAGS) -c -o ./core/ruleset.o core/ruleset.cpp

core/screen.o: core/screen.cpp core/screen.h
	$(CC) $(CFLAGS) -c -o ./core/screen.o core/screen.cpp

core/stock.o: core/stock.cpp core/stock.h
	$(CC) $(CFLAGS) -c -o ./core/stock.o core/stock.cpp

clean:
	rm indicators/*.o
	rm backtest/*.o
	rm core/*.o
	rm data/*.o
	rm screen.o
	rm btest.o
	rm *.bin

test:
	mv ptabs ptabs.prod
	mv ptabs.test ptabs

prod:
	mv ptabs ptabs.test
	mv ptabs.prod ptabs
