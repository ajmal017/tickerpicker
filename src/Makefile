CC=g++
CFLAGS= -I /usr/local/include/ta-lib/ -L/usr/local/lib64/ -lta_lib 

app: indicators other
	g++ $(CFLAGS) *.o

indicators:
	$(CC) $(CFLAGS) -c -o indicators.o indicators.cpp

other: main.o date.o pdata.o ptable.o ruleset.o rulesorter.o screen.o stock.o

clean:
	rm *.o
	rm a.out
