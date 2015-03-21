#include "rapidjson/document.h"
#include <iostream>
#include <vector>
#include "screen.h"

using namespace std;

vector<string> get_universe() {
  vector<string> u;
  u.push_back("AAPL");
  return u;
}

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

  string inp;
  rapidjson::Document d;
  getline(cin, inp);

  d.Parse<0>(inp.c_str());
  pair<vector<string>, vector<string> > p = process_screen(d["screen"]);

  vector<string> results, universe = get_universe();
  screen s(p.first, p.second);
  s.set_universe(universe);

  results = s.eval(date(20150319));
  for(int i = 0; i < results.size(); i++) {
    cout << results[i] << endl;
  }
}
