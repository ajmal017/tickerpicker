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
    close_positions(exits, today);
    open_positions(hits, today);
    hits = entry_signals(today);
    exits = exit_signals(today);
    update_equity_curve(today);
    today.next_business_day();
  } 
}

vector<string> portfolio::entry_signals(date today) {

  vector<string> longhits;

  for(int i = 0; i < long_strategies.size(); i++) {
    strategy cur = long_strategies[i];
    vector<string> curhits = cur.entry_signal(today);
    longhits.insert(longhits.begin(), curhits.begin(), curhits.end());
  }

  return longhits;
}

vector<string> portfolio::exit_signals(date today) {
  vector<string> longhits;

  for(int i = 0; i < long_strategies.size(); i++) {
    strategy cur = long_strategies[i];
    vector<string> curhits = cur.exit_signal(today);
    longhits.insert(longhits.begin(), curhits.begin(), curhits.end());
  }

  return longhits;
}

void portfolio::open_positions(vector<string> pos, date sday) {
  for(int i = 0; i < pos.size(); i++) {
    position newpos(sday, pos[i], 1);   
    float cost = newpos.cost();
    if(cost < cur_cash) {
      cur_positions.push_back(newpos);    
      cur_cash -= cost;
    }
  }
}

//It works better to just mark and close all
//positions instead of trying to do everything
//in one sweep.

void portfolio::close_positions(vector<string> pos, date sday) {
  vector<int> closelist;

  if(pos.size() > 0) {
    //first, sweep through all open positions and mark
    for(int i = 0; i < pos.size(); i++) {
      for(int x = 0; x < cur_positions.size(); x++) {
        position p = cur_positions[x];
        if(p.matches(pos[i])) {
          closelist.push_back(x);
        }       
      }
    }
  
    //now close all marked positions
    for(int i = 0; i < closelist.size(); i++) {
      int closeindex = closelist[i];

      position p = cur_positions[closeindex]; 
      cur_positions.erase(cur_positions.begin() + closeindex);
      cur_cash += p.position_value(sday);      
      p.close(sday);

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
