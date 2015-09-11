#include "strategy.h"
#include <iostream>
#include <math.h>

strategy::strategy() {
  trail_stop = NULL;
  init_stop = NULL;
  size_rule = NULL;
}

void strategy::set_universe(vector<std::string> u) {
  enter_signal->set_universe(u);
  xit_signal->set_universe(u);
}

void strategy::entry_trigger(screen* s) {
  enter_trigger = s;
}

void strategy::entry_signal(screen* s) {
  enter_signal = s;
}

void strategy::exit_trigger(screen* s) {
  xit_trigger = s;
}

void strategy::exit_signal(screen* s) {
  xit_signal = s;
}

void strategy::trailing_stop(vector<std::string> trail) {
  trail_stop = expression_parser::parse(trail);
 
  if(init_stop == NULL) {
    init_stop = expression_parser::parse(trail);
  }
}

void strategy::stop_loss(vector<std::string> stop) {
  init_stop = expression_parser::parse(stop);
}

void strategy::sizing_rule(std::vector<std::string> sizerule) {
  size_rule = expression_parser::parse(sizerule);
}

vector<string> strategy::entry_signal(date strat_date, restrictor* filter) {
  vector<string> rval, hits = enter_signal->eval(strat_date, filter);

  for(int i = 0; i < hits.size(); i++) {
    if(! exit_signal(strat_date, hits[i])) {
      rval.push_back(hits[i]);
    }
  }

  return rval;
}

vector<string> strategy::exit_signal(date strat_date, restrictor* filter) {
  return xit_signal->eval(strat_date);
}

bool strategy::exit_signal(date strat_date, std::string ticker) {
  return xit_signal->eval(strat_date, ticker);
}

float strategy::stop_loss(date strat_date, string ticker, bool trail) {
  stock cur(ticker);
  cur.onday(strat_date);
  float rval;

  if(trail && trail_stop) {
    rval = trail_stop->eval(cur);
  } else {
    rval = init_stop->eval(cur);
  }

  return floor(rval * 100) / 100;
}

int strategy::position_size(date strat_date, string ticker) {
  if(size_rule == NULL) {
    return 1;
  } else {
    stock cur(ticker);
    cur.onday(strat_date);
    return floor(size_rule->eval(cur));
  }
}

bool strategy::has_trail() {
  return trail_stop != NULL;
}
