#ifndef CMDLINE
#define CMDLINE
#include "rapidjson/document.h"
#include <fstream>
#include <iostream>
#include <vector>

void tokenize(const std::string& str, std::vector<std::string>& tokens) {
  std::string::size_type lastPos = str.find_first_not_of(",", 0);
  std::string::size_type pos = str.find_first_of(",", lastPos);

  while (std::string::npos != pos || std::string::npos != lastPos) {
    tokens.push_back(str.substr(lastPos, pos - lastPos));
    lastPos = str.find_first_not_of(",", pos);
    pos = str.find_first_of(",", lastPos);
  }
}

std::vector<std::string> get_universe(char *argv[]) {
  std::vector<std::string> u;
  std::string ticker;
  
  if(std::string(argv[2]).compare("-f") == 0) {

    std::ifstream listfile(argv[3]);
    while(getline(listfile, ticker)) {
      u.push_back(ticker);
    }

  } else {
    std::string tlist(argv[3]);
    tokenize(tlist, u);
  }

  return u;
}

std::pair<std::vector<std::string>, std::vector<std::string> > process_screen(rapidjson::Value& v) {
  rapidjson::Value& rules = v["rules"];
  rapidjson::Value& symbols = v["symbols"];
  std::vector<std::string> r, s;

  for(rapidjson::SizeType i = 0; i < rules.Size(); i++) {
    std::string t = rules[i].GetString();
    r.push_back(t);
  }

  for(rapidjson::SizeType i = 0; i < symbols.Size(); i++) {
    std::string t = symbols[i].GetString();
    s.push_back(t);
  }

  return std::make_pair(r, s);
}

#endif
