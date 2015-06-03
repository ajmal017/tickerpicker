#include "config.h"
#include <iostream>

using namespace std;
bool config::multiple_positions;

config::config(rapidjson::Value& cblock) {
  config::multiple_positions = bvalue(cblock, "multipos");
}

bool config::single_pos() {
  return ! config::multiple_positions;
}

bool config::bvalue(rapidjson::Value& cblock, string key) {
  if(cblock.HasMember(key.c_str())) {
    return cblock[key.c_str()].GetBool(); 
  }
}
