#include "position.h"
#include "pdata.h"
#include <iostream>
#include <math.h>

std::map<string, ptable*> position::open_equities;

position::position(date start, string ticker, int shares) {
  this->ticker = ticker;
  open_date = new date(start);
  count = shares;  

  if(open_equities.count(ticker) == 0) {
    ptable* foo = new ptable(ticker);
    open_equities[ticker] = foo;
  }

  ptable* thispos = open_equities[ticker];
  pdata t = thispos->pull_history_by_limit(*open_date, 1);
  open_cost = t.open[0];
  split_fraction = 0.0;
  open = true;
}

position::position(date start, string ticker, int shares, float ocost) {

}

float position::cost() {
  return open_cost * count;
}

float position::position_value(date cur) {
  ptable* thispos = open_equities[ticker];
  return (thispos->pull_close_on_date(cur) * count) + split_fraction;
}

int position::share_count() {
  return count;
}

bool position::matches(string t) {
  return t == ticker;
}

void position::close(date cdate) {
  close_date = new date(cdate);
  ptable* thispos = open_equities[ticker];
  pdata t = thispos->pull_history_by_limit(cdate, 1);
  close_cost = t.open[0];
  open = false;
}

void position::update(date d) {
  split_adjust(d);
}

void position::split_adjust(date d) {
  ptable* thispos = open_equities[ticker];
  pair<uint16_t, uint16_t> split = thispos->is_split_day(d);

  if(*open_date < d && !(split.first == 1 && split.second == 1)) {
    float ratio = ((float) split.first / split.second); 
    float number = count * ((float) split.second / split.first);
    float remainder = number - floorf(number);

    if(remainder > 0) {
      pdata t = thispos->pull_history_by_limit(d, 1);
      split_fraction += (t.open[0] * remainder);
    }

    open_cost = floorf(open_cost * ratio * 100) / 100; 
    count = number; 
  }
}

void position::print_state() {
  cout << "[";
  cout << '"' << open_date->to_s() << "\",";
  cout << '"' << count << "\",";
  cout << '"' << open_cost << "\"";

  if(!open) {
    cout << ',';
    cout << '"' << close_date->to_s() << "\",";
    cout << '"' << close_cost << "\"";
  }

  cout << "]";
}
