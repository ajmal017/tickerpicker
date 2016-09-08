#include "rapidjson/document.h"
#include "common.h"
#include <algorithm>
#include <iostream>
#include <iomanip>
#include <sstream>
#include <vector>
#include "screen.h"

using namespace std;
expression* supplement = NULL;

float eval_supplement(string ticker, date d) {
  try {
    stock cur(ticker);
    cur.onday(d);
    return supplement->eval(cur);
  } catch(exception e) {
    return 0;
  }
}

expression* parse_calc(rapidjson::Value& symbols) {
  vector<string> expvec;

  for(rapidjson::SizeType i = 0; i < symbols.Size(); i++) {
    std::string t = symbols[i].GetString();
    expvec.push_back(t);
  }

  return expression_parser::parse(expvec);
}

int main(int argc, char* argv[]) {

  string inp;
  rapidjson::Document d;
  date today(argv[1]);
  getline(cin, inp);

  d.Parse<0>(inp.c_str());
  screen *s = process_screen(d["screen"]);

  if(d["screen"].HasMember("calc")) {
    supplement = parse_calc(d["screen"]["calc"]);
  }

  vector<string> results, universe = get_universe(argv, 2);
  s->set_universe(universe);
  results = s->eval(today);

  for(int i = 0; i < results.size(); i++) {
    cout << results[i];

    if(supplement != NULL) {
      cout << "\t" << fixed << setprecision(2) << eval_supplement(results[i], today);
    }

    cout << endl;
  }
}


