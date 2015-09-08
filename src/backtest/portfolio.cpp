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
#include <stdexcept>
#include <iostream>
#include <cmath>

using namespace std;

portfolio::portfolio() {
  indicators::set_portfolio(this);
}

//since portfolio only runs once, I'm not
//really sure this is strictly necessary, but
//good practice and all of that....

portfolio::~portfolio() {
  for(int i = 0; i < long_strategies.size(); i++) {
    delete long_strategies[i];
  }

  for(int i = 0; i < cur_positions.size(); i++) {
    delete cur_positions[i];
  }

  for(int i = 0; i < old_positions.size(); i++) {
    delete old_positions[i];
  }
}

void portfolio::set_date_range(date start, date end) {
  firstdate = start;
  lastdate = end;
}

void portfolio::set_long_strategies(vector<strategy> longstrats) {
  for(int i = 0; i < longstrats.size(); i++) {
    strategy* s = new strategy();
    *s = longstrats[i];
    long_strategies.push_back(s);
  }
}

void portfolio::set_universe(vector<std::string> u) {
  for(int i = 0; i < long_strategies.size(); i++) {
    strategy* cur = long_strategies[i];
    cur->set_universe(u);
  }
}

//This is the top level function
//that drives each tick of the test
void portfolio::run() {

  date today = firstdate;
  vector<string> hits, exits;
  vector<strategy*> hitstrats;
  cur_cash = 10000;

  if(!today.is_business_day()) {
    today.next_business_day();
  }

  while(today <= lastdate) {

    close_positions(&exits, today);
    open_positions(&hits, &hitstrats, today);

    entry_signals(today, &hits, &hitstrats);
    exit_signals(today, &exits);

    update_positions(today);
    process_stops(today);
    update_equity_curve(today);

    today.next_business_day();
  } 
}

void portfolio::entry_signals(date today, vector<string>* longhits, vector<strategy*>* hitstrats) {

  std::vector<string>::iterator last;

  for(int i = 0; i < long_strategies.size(); i++) {
    strategy* cur = long_strategies[i];
    vector<string> curhits = cur->entry_signal(today, this);
    longhits->insert(longhits->begin(), curhits.begin(), curhits.end());

    last = std::unique(longhits->begin(), longhits->end());
    longhits->erase(last, longhits->end());

    for(int x = 0; x < curhits.size(); x++) {
      hitstrats->push_back(cur);      
    }
  }
}

//So the quickest way to do this would be to just set the universe
//of the exit screen to the set of positions, and run the screen. Of
//course that's why it won't work, so because of the stupid 
//KERN_INVALID_ADDRESS on touching the universe that just won't go away,
//no matter what I do, I have to use this stupid jury rigged bullshit 
//with a restrictor instead.  Note that this is intensely annoying.

void portfolio::exit_signals(date today, vector<string>* longhits) {
  for(int i = 0; i < cur_positions.size(); i++) {
    position* p = cur_positions[i];

    if(p->exit(today)) {
      longhits->push_back(p->symbol());
    } 
  }
}

void portfolio::process_stops(date today) {

  for(int i = 0; i < cur_positions.size(); i++) {
    position* p = cur_positions[i];

    if(p->stopped_out(today)) {
      cur_positions.erase(cur_positions.begin() + i);
      cur_cash += p->position_value(today);      
      old_positions.push_back(p);    
    } 
  }
}

//Note that the position constructor will throw
//an exception if there is not enough volume
//on the given day to open a position of the given
//size.  In that case the signal is pushed back on
//the list, defering it to the next day.

void portfolio::open_positions(vector<string>* pos, vector<strategy*>* slist, date sday) {

  vector<string> list = *pos;
  vector<strategy*> strats = *slist; 

  pos->clear();
  slist->clear();

  for(int i = 0; i < list.size(); i++) {
    try {
      int count = strats[i]->position_size(sday, list[i]);
      position* newpos = new position(sday, list[i], count, strats[i]);   
      float cost = newpos->cost();

      if(config::slippage != NULL) {
        stock cur(list[i]);
        cur.onday(sday);
        cost += config::slippage->eval(cur);
      }

      if(cost < cur_cash) {
        cur_positions.push_back(newpos);
        cur_cash -= cost;
      }

    } catch(runtime_error e) {

      if(e.what() == position::DEFER_OK) {
        pos->push_back(list[i]);
        slist->push_back(strats[i]);
      }
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
        position* p = cur_positions[x];
        if(p->matches(targets[i])) {
          closelist.push_back(x);
          closeticks.push_back(targets[i]);
        }       
      }
    }

    std::vector<int>::iterator last;
    last = std::unique(closelist.begin(), closelist.end());
    closelist.erase(last, closelist.end());
  
    //now close all marked positions
    for(int i = 0; i < closelist.size(); i++) {
      int closeindex = closelist[i];
      close_position(sday, closeindex, pos, 0);
    }
  }
}

void portfolio::close_position(date sday, int index, vector<string>* pos, float price) {

   position* p = cur_positions[index]; 

   try {

     if(price == 0) {
       p->close(sday);
     } else {
      // p.close(sday, price);
     }

     old_positions.push_back(p);    
     cur_cash += p->position_value(sday);      
     cur_positions.erase(std::remove(cur_positions.begin(), cur_positions.end(), p), cur_positions.end());

   } catch(exception e) {
     pos->push_back(p->symbol()); 
   }
}

void portfolio::update_equity_curve(date d) {
  float posvalues = 0;
 
  for(int i = 0; i < cur_positions.size(); i++) {
    posvalues += cur_positions[i]->position_value(d);
  }
 
  equity_curve.push_back(posvalues + cur_cash);
}

void portfolio::update_positions(date d) {
  for(int i = 0; i < cur_positions.size(); i++) {
    cur_cash += cur_positions[i]->update(d);
  }
}

bool portfolio::skip_ticker(string target) {
  if(config::single_pos()) {
    for(int i = 0; i < cur_positions.size(); i++) {
      if(cur_positions[i]->matches(target)) {
        return true;
      }
    }
  }

  return false;
}

target_list portfolio::get_current_restrictor() {
  vector<string> t;
  for(int i = 0; i < cur_positions.size(); i++) {
    position* p = cur_positions[i];
    t.push_back(p->symbol());  
  }

  target_list skip(t);
  return skip;
}

void portfolio::print_state() {
  cout << "{\"trades\":";
  cout << "[";

  vector<position*> all = old_positions;
  all.insert(all.end(), cur_positions.begin(), cur_positions.end());

  for(int i = 0; i < all.size(); i++) {
    all[i]->print_state();
    if(i < all.size() - 1) {
      cout << ',';
    }
  }

  cout.setf(std::ios::fixed,std::ios::floatfield);
  cout.precision(2);
 
  cout << "],\"stops\":";
  cout << "[";

  for(int i = 0; i < all.size(); i++) {
    all[i]->print_stop_curve();
    if(i < all.size() - 1) {
      cout << ',';
    }
  }
  
 cout << "],\"equity\":[";

  for(int i = 0; i < equity_curve.size(); i++) {
    cout << equity_curve[i];
    if(i < equity_curve.size() - 1) {
      cout << ',';
    }
  }

  cout << "]}";
  cout << endl;
}

int portfolio::position_count() {
  return cur_positions.size();
}

float portfolio::total_return() {
  float start = equity_curve.front();
  float end = equity_curve.back();
  float diff = ((end - start) / start) * 100;
  return floor(diff * 100) / 100;
}

float portfolio::equity() {
  return equity_curve.back();
}

float portfolio::cash() {
  return cur_cash;
}

target_list::target_list(string s) {
  targets.insert(s);
}

target_list::target_list(vector<string> s) {
  for(int i = 0; i < s.size(); i++) {
    targets.insert(s[i]);
  }
}

bool target_list::skip_ticker(string t) {
  return (targets.count(t) > 0);
}
