#include "rapidjson/document.h"
#include <iostream>
#include <sstream>
#include <vector>
#include "portfolio.h"
#include "strategy.h"
#include "screen.h"
#include "common.h"
#include "config.h"

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

  if(side.HasMember("stop")) {
    vector<std::string> stopsyms;
    rapidjson::Value& stop = side["stop"];
    for(rapidjson::SizeType i = 0; i < stop.Size(); i++) {
      std::string t = stop[i].GetString();
      stopsyms.push_back(t);
    }
    sys.stop_loss(stopsyms);
  }

  if(side.HasMember("trail")) {
    vector<std::string> trailsyms;
    rapidjson::Value& trail = side["trail"];
    for(rapidjson::SizeType i = 0; i < trail.Size(); i++) {
      std::string t = trail[i].GetString();
      trailsyms.push_back(t);
    }
    sys.trailing_stop(trailsyms);
  }

  if(side.HasMember("size")) {
    vector<std::string> sizesyms;
    rapidjson::Value& trail = side["size"];
    for(rapidjson::SizeType i = 0; i < trail.Size(); i++) {
      std::string t = trail[i].GetString();
      sizesyms.push_back(t);
    }
    sys.sizing_rule(sizesyms);
  }

//  if(side["exit"].HasMember("trigger")) {
//    pair<vector<string>, vector<string> > e = process_screen(side["exit"]["trigger"]);
//    screen xt(e.first, e.second);
//    sys.exit_trigger(xt);
//  }

  return sys;
}

void process_configuration(rapidjson::Document& doc) {
  if(doc.HasMember("config")) {
    config t(doc["config"]); 
  }
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
  process_configuration(d);

  port.run();
  port.print_state();
}
