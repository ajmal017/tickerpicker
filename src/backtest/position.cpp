#include "position.h"
#include "pdata.h"
#include <iostream>
#include <math.h>

std::map<string, ptable*> position::open_equities;

position::position(date start, string ticker, int shares, strategy* strat) {
  this->ticker = ticker;
  open_date = new date(start);
  this_strat = strat;
  count = shares;  

  if(open_equities.count(ticker) == 0) {
    ptable* foo = new ptable(ticker);
    open_equities[ticker] = foo;
  }

  ptable* thispos = open_equities[ticker];
  pdata t = thispos->pull_history_by_limit(*open_date, 1);
  date pulled = date(t.date[0]);

  if(t.volume[0] < shares || start != pulled) {
    throw exception();
  }

  open_cost = t.open[0];
  split_fraction = 0.0;
  open = true;
}

position::position(date start, string ticker, int shares, strategy* strat, float ocost) {
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
  date pulled = date(t.date[0]);

  if(t.volume[0] < count || cdate != pulled) {
    throw exception();
  } 

  close_cost = t.open[0];
  open = false;
}

bool position::exit(date edate) {
  vector<string> t = this_strat->exit_signal(edate, this);
  return t.size() > 0;
}

bool position::stopped_out(date cdate) {
  ptable* thispos = open_equities[ticker];
  pdata t = thispos->pull_history_by_limit(cdate, 1);

  if(t.volume[0] >= count) {
    close_date = new date(cdate);
    float stop = this_strat->stop_loss(cdate, ticker); 

    if(stop >= t.low[0]) {
      close_cost = stop;
      open = false;
    }
  } 

  return ! open;
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

string position::symbol() {
  return ticker;
}

float position::percent_diff() {
  float diff = ((close_cost - open_cost) / open_cost) * 100;
  return floor(diff * 100) / 100;
}

void position::print_state() {
  cout << "[";
  cout << '"' << open_date->to_s() << "\",";
  cout << '"' << count << "\",";
  cout << '"' << open_cost << "\"";

  if(!open) {
    cout << ',';
    cout << '"' << close_date->to_s() << "\",";
    cout << '"' << close_cost << "\",";
    cout << '"' << percent_diff() << "\"";
  }

  cout << "]";
}

bool position::skip_ticker(string t) {
  return t != ticker;
}
