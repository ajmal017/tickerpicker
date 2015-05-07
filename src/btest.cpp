#include "rapidjson/document.h"
#include <sstream>
#include <iostream>
#include <vector>
#include "common.h"
#include "strategy.h"
#include "screen.h"

using namespace std;

void process_strategy(rapidjson::Document& doc, strategy *sys, string dir) {

  rapidjson::Value& side = doc[dir.c_str()];

  if(side["enter"].HasMember("signal")) {
    pair<vector<string>, vector<string> > e = process_screen(side["enter"]["signal"]);
    screen es(e.first, e.second);
    sys->long_entry_signal(es);
  }

  if(side["enter"].HasMember("trigger")) {
    pair<vector<string>, vector<string> > e = process_screen(side["enter"]["trigger"]);
    screen et(e.first, e.second);
    sys->long_entry_trigger(et);
  }

  if(side["exit"].HasMember("signal")) {
    pair<vector<string>, vector<string> > e = process_screen(side["exit"]["signal"]);
    screen xs(e.first, e.second);
    sys->long_exit_signal(xs);
  }

  if(side["exit"].HasMember("trigger")) {
    pair<vector<string>, vector<string> > e = process_screen(side["exit"]["trigger"]);
    screen xt(e.first, e.second);
    sys->long_exit_trigger(xt);
  }
}


int main(int argc, char* argv[]) {

  string inp;
  rapidjson::Document d;
  strategy strat;

  getline(cin, inp);
  d.Parse<0>(inp.c_str());
  process_strategy(d, &strat, "long");

  strat.set_date_range(date(argv[0]), date(argv[1]));
  vector<string> universe = get_universe(argv);
  strat.set_universe(universe);

  strat.evaluate();

}
