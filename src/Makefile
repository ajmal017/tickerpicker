CC=g++
TAFLAGS= -I /usr/local/include/ta-lib/ -L/usr/local/lib64/ -lta_lib
CFLAGS= -I data -I indicators -I core

app: screen.o btest.o indicator data core
	$(CC) $(TAFLAGS) ./data/*.o ./indicators/*.o ./core/*.o screen.o -o screen.bin 
	$(CC) $(TAFLAGS) ./data/*.o ./indicators/*.o ./core/*.o btest.o -o btest.bin 

indicator: indicators/indicators.o indicators/lookbacks.o indicators/tables.o indicators/math.o

data: data/date.o data/pdata.o data/ptable.o

core: core/ruleset.o core/rulesorter.o core/screen.o core/stock.o

btest.o : btest.cpp
	$(CC) $(CFLAGS) $(TAFLAGS) -c -o btest.o btest.cpp

screen.o : screen.cpp
	$(CC) $(CFLAGS) $(TAFLAGS) -c -o screen.o screen.cpp

indicators/indicators.o: indicators/indicators.cpp
	$(CC) $(CFLAGS) $(TAFLAGS) -c -o ./indicators/indicators.o indicators/indicators.cpp

indicators/lookbacks.o: indicators/lookbacks.cpp
	$(CC) $(CFLAGS) $(TAFLAGS) -c -o ./indicators/lookbacks.o indicators/lookbacks.cpp

indicators/tables.o: indicators/tables.cpp
	$(CC) $(CFLAGS) -c -o ./indicators/tables.o indicators/tables.cpp

indicators/math.o: indicators/math.cpp
	$(CC) $(CFLAGS) -c -o ./indicators/math.o indicators/math.cpp

data/date.o: data/date.cpp data/date.h
	$(CC) $(CFLAGS) -c -o ./data/date.o data/date.cpp

data/pdata.o: data/pdata.cpp data/pdata.h
	$(CC) $(CFLAGS) -c -o ./data/pdata.o data/pdata.cpp

data/ptable.o: data/ptable.cpp data/ptable.h
	$(CC) $(CFLAGS) -c -o ./data/ptable.o data/ptable.cpp

core/ruleset.o: core/ruleset.cpp core/ruleset.h
	$(CC) $(CFLAGS) -c -o ./core/ruleset.o core/ruleset.cpp

core/rulesorter.o: core/rulesorter.cpp
	$(CC) $(CFLAGS) -c -o ./core/rulesorter.o core/rulesorter.cpp

core/screen.o: core/screen.cpp core/screen.h
	$(CC) $(CFLAGS) -c -o ./core/screen.o core/screen.cpp

core/stock.o: core/stock.cpp core/stock.h
	$(CC) $(CFLAGS) -c -o ./core/stock.o core/stock.cpp

clean:
	rm indicators/*.o
	rm core/*.o
	rm data/*.o
	rm screen.o
	rm screen.bin

test:
	mv ptabs ptabs.prod
	mv ptabs.test ptabs

prod:
	mv ptabs ptabs.test
	mv ptabs.prod ptabs
