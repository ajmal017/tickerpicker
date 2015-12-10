#include "portfolio.h"
#include <stdlib.h>

void deposits::add_deposits(vector<string> sched) {

  for(int i = 0; i < sched.size(); i++) {
    process_deposit(sched[i]);
  }
}

float deposits::update() {
  float total = 0.0;

  for(int i = 0; i < counters.size(); i++) {

    counters[i]++;

    if(counters[i] == periods[i]) {
      total += amounts[i];
      counters[i] = 0;
      continue;
    }
  }

  return total;
}

void deposits::process_deposit(string d) {
  std::size_t found = d.find_first_of("/");
  string days = d.substr(0, found);
  string amt = d.substr(found + 1);

  periods.push_back(atoi(days.c_str()));
  amounts.push_back(atof(amt.c_str()));
  counters.push_back(0);
}
