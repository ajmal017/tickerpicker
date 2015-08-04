#include "strategy.h"
#include <iostream>
#include <math.h>

strategy::strategy() {

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
}

void strategy::stop_loss(vector<std::string> stop) {
  init_stop = expression_parser::parse(stop);
}

vector<string> strategy::entry_signal(date strat_date, restrictor* filter) {
  return enter_signal->eval(strat_date, filter);
}

vector<string> strategy::exit_signal(date strat_date, restrictor* filter) {
  return xit_signal->eval(strat_date);
}

float strategy::stop_loss(date strat_date, string ticker) {
  stock cur(ticker);
  cur.onday(strat_date);
  float rval = init_stop->eval(cur);
  return floor(rval * 100) / 100;
}
