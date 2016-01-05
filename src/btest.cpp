#include "rapidjson/document.h"
#include <algorithm>
#include <iostream>
#include <sstream>
#include <vector>
#include <ctime>
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
    screen* es = process_screen(side["enter"]["signal"]);
    sys.entry_signal(es);
  }

//  if(side["enter"].HasMember("trigger")) {
//    pair<vector<string>, vector<string> > e = process_screen(side["enter"]["trigger"]);
//    screen et(e.first, e.second);
//    sys.entry_trigger(et);
//  }

  if(side["exit"].HasMember("signal")) {
    screen* xs = process_screen(side["exit"]["signal"]);
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

void process_deposits(rapidjson::Document& doc, portfolio* p) {
  if(doc.HasMember("deposits")) {
    vector<string> deposits;
    rapidjson::Value& schedule = doc["deposits"];

    for(rapidjson::SizeType i = 0; i < schedule.Size(); i++) {
      std::string t = schedule[i].GetString();
      deposits.push_back(t);
    }
   
    p->set_deposit_schedule(deposits);
  }
}

void subtract_vector(std::vector<std::string>& a, const std::vector<std::string>& b) {
  std::vector<std::string>::iterator       it = a.begin();                                                          
  std::vector<std::string>::const_iterator it2 = b.begin();                                                     
  std::vector<std::string>::iterator       end = a.end();                                                           
  std::vector<std::string>::const_iterator end2 = b.end();                                                      

  while (it != end) {
    while (it2 != end2) {
      if (*it == *it2) {
        it = a.erase(it);                                                                                
        end = a.end();                                                                                   
        it2 = b.begin();                                                                                         
      } else {
        ++it2; 
      }
    }

    ++it;
    it2 = b.begin();
  }
}

void process_blacklist(rapidjson::Document& doc, std::vector<std::string>& u) {
  if(doc.HasMember("blacklist")) {
    vector<string> blist;
    rapidjson::Value &list = doc["blacklist"];
    for(rapidjson::SizeType i = 0; i < list.Size(); i++) {
      std::string t = list[i].GetString();
      blist.push_back(t);
    }

    subtract_vector(u, blist);
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

  process_configuration(d);
  port.set_date_range(date(argv[1]), date(argv[2]));
  vector<string> universe = get_universe(argv, 3);
  process_blacklist(d, universe);

  if(config::shuffle()) {
    std::srand(std::time(0));
    std::random_shuffle(universe.begin(), universe.end());
  }

  port.set_long_strategies(longstrats);
  port.set_universe(universe);
  process_deposits(d, &port);

  port.run();
  port.print_state();
}
