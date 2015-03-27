#include "ptable.h"
#include <vector>
#include <iostream>

int pdata::size() {
  return close.size();
}

bool pdata::is_valid(::date sdate, int len) {

  if(date.size() <= 0) {
    return false;
  }

  ::date firstdate(date[0]);

  if(sdate.diff_bdays(firstdate) > MAX_OLD) {
    return false;
  }

  return true;
}

bool pdata::has_gaps() {

  ::date day1(date[0]);

  for(int i = 1; i < date.size(); i++) {
    ::date day2(date[i]);
    if(day1.diff_bdays(day2) > MAX_GAP) {
      return true;
    }

    day1 = day2;
  }

  return false;
}

void pdata::concat_history(pdata newdata) {
  low.insert(low.end(), newdata.low.begin(), newdata.low.end());
  open.insert(open.end(), newdata.open.begin(), newdata.open.end());
  high.insert(high.end(), newdata.high.begin(), newdata.high.end());
  close.insert(close.end(), newdata.close.begin(), newdata.close.end());
  volume.insert(volume.end(), newdata.volume.begin(), newdata.volume.end());
  date.insert(date.end(), newdata.date.begin(), newdata.date.end());
}

void pdata::clear() {
  low.clear();
  open.clear();
  high.clear();
  close.clear();
  volume.clear();
  date.clear();
}
