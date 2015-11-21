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
#include <algorithm>
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

//  for(int i = 0; i < old_positions.size(); i++) {
//    delete old_positions[i];
//  }
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
  update_benchmark(today);
  vector<string> hits, exits;
  vector<strategy*> hitstrats;
  cur_cash = 10000;

  if(!today.is_business_day()) {
    today.next_business_day();
  }

  while(today <= lastdate) {

    close_positions(&exits, today);
    open_positions(&hits, &hitstrats, today);

    update_positions(today);
    entry_signals(today, &hits, &hitstrats);
    exit_signals(today, &exits);

    process_stops(today);
    update_equity_curve(today);

    today.next_business_day();
  } 

  update_benchmark(today);
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
      past_performance.push(p);
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

      if(count > 0) {

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

     past_performance.push(p);
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
 
  past_performance.update_equity(posvalues + cur_cash);
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

void portfolio::update_benchmark(date d) {
  if(config::benchmark() != "") {
    ptable* foo = new ptable(config::benchmark());
    pdata t = foo->pull_history_by_limit(d, 1);
    past_performance.push_benchmark(t.close[0]);
  }
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
  past_performance.print_state(cur_positions);
}

int portfolio::position_count() {
  return cur_positions.size();
}

float portfolio::total_return() {
  return past_performance.total_return();
}

float portfolio::equity() {
  return past_performance.current_equity();
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
