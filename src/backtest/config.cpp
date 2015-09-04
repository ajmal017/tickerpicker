#include "config.h"
#include <iostream>
#include <vector>

using namespace std;
expression* config::slippage;
bool config::multiple_positions;

config::config(rapidjson::Value& cblock) {
  config::slippage = NULL;

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
}

bool config::single_pos() {
  return ! config::multiple_positions;
}

bool config::bvalue(rapidjson::Value& cblock, string key) {
  if(cblock.HasMember(key.c_str())) {
    return cblock[key.c_str()].GetBool(); 
  }
}
