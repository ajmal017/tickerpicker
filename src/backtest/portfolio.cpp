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

void portfolio::run() {

  date today = *firstdate;
  vector<string> hits, exits;

  while(today <= *lastdate) {
    close_positions(exits, today);
    open_positions(hits, today);
    hits = entry_signals(today);
    exits = exit_signals(today);
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
    cur_positions.push_back(newpos);    
  }
}

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
      old_positions.push_back(p);    
    }
  }
}
