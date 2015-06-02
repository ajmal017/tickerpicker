#include "strategy.h"
#include <iostream>

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

vector<string> strategy::entry_signal(date strat_date, restrictor* filter) {
  return enter_signal->eval(strat_date, filter);
}

vector<string> strategy::exit_signal(date strat_date) {
  return xit_signal->eval(strat_date);
}
