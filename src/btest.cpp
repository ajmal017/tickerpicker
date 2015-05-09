#include "rapidjson/document.h"
#include <iostream>
#include <sstream>
#include <vector>
#include "portfolio.h"
#include "strategy.h"
#include "screen.h"
#include "common.h"

using namespace std;

strategy process_strategy(rapidjson::Document& doc, string dir) {

  rapidjson::Value& side = doc[dir.c_str()];
  strategy sys;

  if(side["enter"].HasMember("signal")) {
    pair<vector<string>, vector<string> > e = process_screen(side["enter"]["signal"]);
    screen *es = new screen(e.first, e.second);
    sys.entry_signal(es);
  }

//  if(side["enter"].HasMember("trigger")) {
//    pair<vector<string>, vector<string> > e = process_screen(side["enter"]["trigger"]);
//    screen et(e.first, e.second);
//    sys.entry_trigger(et);
//  }

  if(side["exit"].HasMember("signal")) {
    pair<vector<string>, vector<string> > e = process_screen(side["exit"]["signal"]);
    screen *xs = new screen(e.first, e.second);
    sys.exit_signal(xs);
  }

//  if(side["exit"].HasMember("trigger")) {
//    pair<vector<string>, vector<string> > e = process_screen(side["exit"]["trigger"]);
//    screen xt(e.first, e.second);
//    sys.exit_trigger(xt);
//  }

  return sys;
}

int main(int argc, char* argv[]) {

  string inp;
  rapidjson::Document d;
  portfolio port;

  getline(cin, inp);
  d.Parse<0>(inp.c_str());
  vector<strategy> longstrats;
  strategy strat = process_strategy(d, "long");
  longstrats.push_back(strat);

  port.set_date_range(date(argv[1]), date(argv[2]));
  vector<string> universe = get_universe(argv, 3);

  port.set_long_strategies(longstrats);
  port.set_universe(universe);

  port.run();
}
