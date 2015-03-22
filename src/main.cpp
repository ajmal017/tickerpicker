#include "rapidjson/document.h"
#include <sstream>
#include <algorithm>
#include <iostream>
#include <vector>
#include "screen.h"

using namespace std;

void tokenize(const string& str, vector<string>& tokens) {
  string::size_type lastPos = str.find_first_not_of(",", 0);
  string::size_type pos = str.find_first_of(",", lastPos);

  while (string::npos != pos || string::npos != lastPos) {
    tokens.push_back(str.substr(lastPos, pos - lastPos));
    lastPos = str.find_first_not_of(",", pos);
    pos = str.find_first_of(",", lastPos);
  }
}

vector<string> get_universe(char *argv[]) {
  vector<string> u;
  string ticker;
  
  if(string(argv[2]).compare("-f") == 0) {

    ifstream listfile(argv[3]);
    while(getline(listfile, ticker)) {
      u.push_back(ticker);
    }

  } else {
    string tlist(argv[3]);
    tokenize(tlist, u);
  }

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

int main(int argc, char* argv[]) {

  string inp;
  rapidjson::Document d;
  getline(cin, inp);

  d.Parse<0>(inp.c_str());
  pair<vector<string>, vector<string> > p = process_screen(d["screen"]);

  vector<string> results, universe = get_universe(argv);
  screen s(p.first, p.second);
  s.set_universe(universe);

  results = s.eval(date(argv[1]));
  sort(results.begin(), results.end());

  for(int i = 0; i < results.size(); i++) {
    cout << results[i] << endl;
  }
}
