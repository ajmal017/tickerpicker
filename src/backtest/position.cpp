#include "position.h"
#include "pdata.h"
#include <iostream>
#include <math.h>
#include <stdexcept>

std::map<string, ptable*> position::open_equities;
const std::string position::DEFER_OK = "defer";

position::position(date start, string ticker, int shares, strategy* strat) {
  open_date = new date(start);
  cur_date = new date(start);
  this->ticker = ticker;
  this_strat = strat;
  total_payout = 0;
  count = shares;  

  if(open_equities.count(ticker) == 0) {
    ptable* foo = new ptable(ticker);
    open_equities[ticker] = foo;
  }

  ptable* thispos = open_equities[ticker];
  pdata t = thispos->pull_history_by_limit(*open_date, 1);
  date pulled = date(t.date[0]);
  open_cost = t.open[0];

  indicators::set_position(this);
  float stop = this_strat->stop_loss(start, ticker, false); 
  stop_history.push_back(stop);

  //if we have insufficient volume or a date miss
  if(t.volume[0] < shares || start != pulled) {
    throw runtime_error(DEFER_OK);
  }

  //if we'd be stopped out right away
  if(t.open[0] <= stop) {
    throw runtime_error("");
  }

  if(dividends::exists(ticker)) {
    divdata = new dividends(ticker);
  } else {
    divdata = NULL;
  }

  open = true;
}

position::position(date start, string ticker, int shares, strategy* strat, float ocost) {
}

float position::cost() {
  return open_cost * count;
}

float position::position_value(date cur) {
  ptable* thispos = open_equities[ticker];
  return (thispos->pull_close_on_date(cur) * count);
}

int position::share_count() {
  return count;
}

void position::close(date cdate) {
  close_date = new date(cdate);
  ptable* thispos = open_equities[ticker];
  pdata t = thispos->pull_history_by_limit(cdate, 1);
  date pulled = date(t.date[0]);

  if(t.volume[0] < count || cdate != pulled) {
    throw exception();
  } 

  if(divdata != NULL) {
    delete divdata;
    divdata = NULL;
  }

  close_cost = t.open[0];
  open = false;
}

bool position::exit(date edate) {
  indicators::set_position(this);
  vector<string> t = this_strat->exit_signal(edate, this);
  return t.size() > 0;
}

bool position::stopped_out(date cdate) {
  if(open) {
    ptable* thispos = open_equities[ticker];
    pdata t = thispos->pull_history_by_limit(cdate, 1);
  
    if(t.volume[0] >= count) {
      close_date = new date(cdate);
      float stop = stop_history.back();
  
      if(stop >= t.low[0]) {
        close_cost = (t.open[0] < stop ? t.open[0] : stop);
        open = false;
      }
    } 
  }

  return ! open;
}

float position::update(date d) {
  float rval = split_adjust(d);
  rval += dividend(d);
  update_stop(d);
  *cur_date = d;
  return rval;
}

float position::split_adjust(date d) {
  ptable* thispos = open_equities[ticker];
  pair<uint16_t, uint16_t> split = thispos->is_split_day(d);
  float cash_in_lieu = 0.0;

  if(*open_date < d && !(split.first == 1 && split.second == 1)) {
    float ratio = ((float) split.first / split.second); 
    float iratio = ((float) split.second / split.first); 
    float number = floorf(count * iratio);
    float remainder = (count * iratio) - number;

    if(remainder > 0) {
      pdata t = thispos->pull_history_by_limit(d, 1);
      cash_in_lieu = (t.open[0] * remainder);
      cash_in_lieu = floorf(cash_in_lieu * 100) / 100;
    }

    for(int i = 0; i < stop_history.size(); i++) {
      stop_history[i] = stop_history[i] * ratio; 
    }

    open_cost = floorf(open_cost * ratio * 100) / 100; 
    count = number; 
  }

  return cash_in_lieu;
}

float position::dividend(date d) {
  if(divdata != NULL) {
    float rval = divdata->on_date(d) * count;
    total_payout += rval;
    return rval;
  }

  return 0;
}

void position::update_stop(date d) {

  if(open_date->to_s() != d.to_s()) {
    float old = stop_history.back();

    if(this_strat->has_trail()) {
      float stop = this_strat->stop_loss(d, ticker, true);
      stop_history.push_back((stop > old ? stop : old));
    } else {
      stop_history.push_back(old);
    }
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
  cout << '"' << ticker << "\",";
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

void position::print_stop_curve() {
  cout << "[";
  
  for(int i = 0; i < stop_history.size(); i++) {
    cout << stop_history[i];
    if(i < stop_history.size() - 1) {
      cout << ",";
    }
  }

  cout << "]";
}

bool position::skip_ticker(string t) {
  return t != ticker;
}

float position::purchase_price() {
  return open_cost;
}

float position::percent_return() {
  ptable* thispos = open_equities[ticker];
  pdata t = thispos->pull_history_by_limit(*cur_date, 1);
  float cur_cost = t.close[0];

  float diff = ((cur_cost - open_cost) / open_cost) * 100;
  return floor(diff * 100) / 100;
}

float position::risk_return() {
  float risk = ((open_cost - stop_history[0]) / open_cost) * 100;
  float percent = percent_return();
  return floor((percent / risk) * 100) / 100;
}

float position::div_payout() {
  return total_payout;
}

float position::days_held() {
  return stop_history.size();
}
