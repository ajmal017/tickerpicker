#include "config.h"
#include <iostream>
#include <vector>

using namespace std;
string config::benchticker;
expression* config::slippage;
bool config::multiple_positions;
bool config::shuffle_universe;
float config::start_equity;

config::config(rapidjson::Value& cblock) {
  config::slippage = NULL;
  config::benchticker = "";
  config::start_equity = 10000;
  config::shuffle_universe = false;

  config::multiple_positions = bvalue(cblock, "multipos");
  rapidjson::Value& slippage = cblock["slippage"];

  if(slippage.Size() > 0) {
    vector<std::string> slipsymbols;
    for(rapidjson::SizeType i = 0; i < slippage.Size(); i++) {
      std::string t = slippage[i].GetString();
      slipsymbols.push_back(t);
    }
  
    config::slippage = expression_parser::parse(slipsymbols); 
  }

  if(cblock.HasMember("benchmark")) {
    config::benchticker = cblock["benchmark"].GetString();
  }

  if(cblock.HasMember("equity")) {
    string t = cblock["equity"].GetString();
    config::start_equity = atof(t.c_str());
  }

  if(cblock.HasMember("shuffle")) {
    shuffle_universe = bvalue(cblock, "shuffle");
  }
}

float config::initial_equity() {
  return start_equity;
}

bool config::single_pos() {
  return ! config::multiple_positions;
}

bool config::bvalue(rapidjson::Value& cblock, string key) {
  if(cblock.HasMember(key.c_str())) {
    return cblock[key.c_str()].GetBool(); 
  }
}

string config::benchmark() {
  return config::benchticker;
}

bool config::shuffle() {
  return config::shuffle_universe;
}
