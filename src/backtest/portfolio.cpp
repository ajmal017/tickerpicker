/* This is the top level construct that drives a backtest.  It emulates a 
 * portfolio, which consists of one or more positions and some amount of cash.
 * The algorithm is that triggers (intraday criteria) are evaluated first, and
 * then signals (interday criteria).  Triggers execute and update the portfolio
 * right away, while signals are queued until the next day (next bar on the price
 * chart).  The equity curve is updated with close of day prices for each day of
 * the simulation.
 */

#include "portfolio.h"
#include "position.h"
#include <iostream>

using namespace std;

void portfolio::set_date_range(date start, date end) {
  firstdate = &start;
  lastdate = &end;
}

void portfolio::set_long_strategies(vector<strategy> longstrats) {
  long_strategies = longstrats;
}

void portfolio::set_universe(vector<std::string> u) {
  for(int i = 0; i < long_strategies.size(); i++) {
    strategy cur = long_strategies[i];
    cur.set_universe(u);
  }
}

//This is the top level function
//that drives each tick of the test
void portfolio::run() {

  date today = *firstdate;
  vector<string> hits, exits;
  cur_cash = 10000;

  while(today <= *lastdate) {
    close_positions(&exits, today);
    open_positions(&hits, today);
    entry_signals(today, &hits);
    exit_signals(today, &exits);
    update_equity_curve(today);
    update_positions(today);
    today.next_business_day();
  } 
}

void portfolio::entry_signals(date today, vector<string>* longhits) {

  for(int i = 0; i < long_strategies.size(); i++) {
    strategy cur = long_strategies[i];
    vector<string> curhits = cur.entry_signal(today, this);
    longhits->insert(longhits->begin(), curhits.begin(), curhits.end());
  }
}

void portfolio::exit_signals(date today, vector<string>* longhits) {

  for(int i = 0; i < long_strategies.size(); i++) {
    strategy cur = long_strategies[i];
    vector<string> curhits = cur.exit_signal(today);
    longhits->insert(longhits->begin(), curhits.begin(), curhits.end());
  }
}

//Note that the position constructor will throw
//an exception if there is not enough volume
//on the given day to open a position of the given
//size.  In that case the signal is pushed back on
//the list, defering in to the next day.

void portfolio::open_positions(vector<string>* pos, date sday) {
  vector<string> list = *pos;
  pos->clear();

  for(int i = 0; i < list.size(); i++) {
    try {
      position newpos(sday, list[i], 1);   
      float cost = newpos.cost();

      if(cost < cur_cash) {
        cur_positions.push_back(newpos);    
        cur_cash -= cost;
      }

    } catch(exception e) {
      pos->push_back(list[i]);
    }
  }
}

//It works better to just mark and close all
//positions instead of trying to do everything
//in one sweep. As with opening positions, if there's
//not enough volume to sell that day, an exception
//is thrown and the signal will be pushed back
//on to the sell list and tried the next day

void portfolio::close_positions(vector<string>* pos, date sday) {
  vector<int> closelist;
  vector<string> closeticks;

  if(pos->size() > 0) {
    vector<string> targets = *pos;
    pos->clear();

    //first, sweep through all open positions and mark
    for(int i = 0; i < targets.size(); i++) {
      for(int x = 0; x < cur_positions.size(); x++) {
        position p = cur_positions[x];
        if(p.matches(targets[i])) {
          closelist.push_back(x);
          closeticks.push_back(targets[i]);
        }       
      }
    }
  
    //now close all marked positions
    for(int i = 0; i < closelist.size(); i++) {
      int closeindex = closelist[i];
      position p = cur_positions[closeindex]; 

      try {
        p.close(sday);
      } catch(exception e) {
        pos->push_back(closeticks[i]); 
        continue;
      }

      cur_positions.erase(cur_positions.begin() + closeindex);
      cur_cash += p.position_value(sday);      
      old_positions.push_back(p);    
    }
  }
}

void portfolio::update_equity_curve(date d) {
  float posvalues = 0;

  for(int i = 0; i < cur_positions.size(); i++) {
    posvalues += cur_positions[i].position_value(d);
  }

  equity_curve.push_back(posvalues + cur_cash);
}

void portfolio::update_positions(date d) {
  for(int i = 0; i < cur_positions.size(); i++) {
    cur_positions[i].update(d);
  }
}

bool portfolio::skip_ticker(string target) {
  if(config::single_pos()) {
    for(int i = 0; i < cur_positions.size(); i++) {
      if(cur_positions[i].matches(target)) {
        return true;
      }
    }
  }

  return false;
}

void portfolio::print_state() {
  cout << "{\"trades\":";
  cout << "[";

  vector<position> all = old_positions;
  all.insert(all.end(), cur_positions.begin(), cur_positions.end());

  for(int i = 0; i < all.size(); i++) {
    all[i].print_state();
    if(i < all.size() - 1) {
      cout << ',';
    }
  }

  cout << "]}";
  cout << endl;
}
