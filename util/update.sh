#! /bin/sh

START_DATE=`/bin/date -v -9d '+%m-%d-%Y'`
END_DATE=`/bin/date '+%m-%d-%Y'`
DEFAULT_SOURCE=true

rm amex.txt nasdaq.txt nyse.txt
./gettickers.rb


if $DEFAULT_SOURCE; then
  # Yahoo default
  ./gethistory.rb -l amex.txt -s $START_DATE -e $END_DATE -u root -p password
  ./gethistory.rb -l nyse.txt -s $START_DATE -e $END_DATE -u root -p password
  ./gethistory.rb -l nasdaq.txt -s $START_DATE -e $END_DATE -u root -p password
else
  ./gethistory.rb -l amex.txt -s $START_DATE -e $END_DATE -u root -p password  --google --exchange amex
  ./gethistory.rb -l nyse.txt -s $START_DATE -e $END_DATE -u root -p password --google --exchange nyse
  ./gethistory.rb -l nasdaq.txt -s $START_DATE -e $END_DATE -u root -p password --google --exchange nasdaq
fi
