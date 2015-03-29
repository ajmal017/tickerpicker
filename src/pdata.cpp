#include "ptable.h"
#include <vector>
#include <algorithm>
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
  concat_prices(newdata);
  concat_splits(newdata);
}

void pdata::concat_prices(pdata newdata) {
  low.insert(low.end(), newdata.low.begin(), newdata.low.end());
  open.insert(open.end(), newdata.open.begin(), newdata.open.end());
  high.insert(high.end(), newdata.high.begin(), newdata.high.end());
  close.insert(close.end(), newdata.close.begin(), newdata.close.end());
  volume.insert(volume.end(), newdata.volume.begin(), newdata.volume.end());
  date.insert(date.end(), newdata.date.begin(), newdata.date.end());
}

void pdata::concat_splits(pdata newdata) {
  std::map<uint32_t, pair<uint16_t, uint16_t> >::iterator it;

  //apply existing splits first
  //starting from first day of new data
  ::date firstday(newdata.date[0]);
  for(it = splitlist.begin(); it != splitlist.end(); it++) {
    apply_split(firstday, it->second.first, it->second.second);
  }

  //now add new splits to splitlist
  for(it = newdata.splitlist.begin(); it != newdata.splitlist.end(); it++) {
    splitlist[it->first] = it->second; 
  }
}

void pdata::clear() {
  low.clear();
  open.clear();
  high.clear();
  close.clear();
  volume.clear();
  date.clear();
}

void pdata::add_split(::date d, pair<uint16_t, uint16_t> split) {
  apply_split(d, split.first, split.second);
  splitlist[d.int_image()] = split;
}

void pdata::apply_split(::date d, uint16_t before, uint16_t after) {
  vector<uint32_t>::iterator it = find(date.begin(), date.end(), d.int_image());
  float ratio = (float)before / after;

  for(int i = it - date.begin() + 1; i < size(); i++) {
    low[i] *= ratio;
    high[i] *= ratio;
    open[i] *= ratio;
    close[i] *= ratio;
  }
}

void pdata::dump_data() {
  for(int i = 0; i < size(); i++) {
    ::date d(date[i]);
    cout << d.to_s() << "\t";
    cout << open[i] << "\t";
    cout << high[i] << "\t";
    cout << low[i] << "\t";
    cout << close[i] << "\t";
    cout << volume[i] << "\n";
  }
}
