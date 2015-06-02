#include "screen.h"
#include <iostream>

map<string, stock> screen::all;

screen::screen(vector<string> rules, vector<string> table) {
  srules = new ruleset(rules, table);
}

void screen::set_universe(vector<string> list) {
  universe = list;
}

vector<string> screen::eval(date curdate, restrictor* filter) {

  vector<string> results;

  for(int i = 0; i < universe.size(); i++) {

    string ticker = universe[i];

    if(filter != NULL && filter->skip_ticker(ticker)) {
      continue;
    }

    if(all.count(ticker) == 0) {

      try {
        stock cur(ticker);
        all.insert(std::pair<string, stock>(ticker, cur));
      } catch(exception e) {
        continue;
      }
      
    }

    stock cur = all.find(ticker)->second; 
    cur.onday(curdate);

    if(srules->eval(cur)) {
      results.push_back(ticker);
    }
  }

  return results;
}
