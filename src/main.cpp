#include "rapidjson/document.h"
#include "ruleset.h"
#include <iostream>
#include <vector>
using namespace std;

pair<vector<string>, vector<string> > process_screen(rapidjson::Value& v) {
  rapidjson::Value& rules = v["rules"];
  rapidjson::Value& symbols = v["symbols"];
  vector<string> r, s;

  for(rapidjson::SizeType i = 0; i < rules.Size(); i++) {
    string t = rules[i].GetString();
    r.push_back(t);
  }

  for(rapidjson::SizeType i = 0; i < symbols.Size(); i++) {
    string t = symbols[i].GetString();
    s.push_back(t);
  }

  return std::make_pair(r, s);
}

int main(int argc, const char* argv[]) {

  rapidjson::Document d;
  string def, buf;

  while(getline(cin, buf)) {
    def += buf;
  }

  d.Parse<0>(def.c_str());
  pair<vector<string>, vector<string> > p = process_screen(d["screen"]);
  ruleset s(p.first, p.second);

  stock target("AAPL");
  s.eval(target);
}
