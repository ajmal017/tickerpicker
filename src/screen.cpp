#include "rapidjson/document.h"
#include "common.h"
#include <sstream>
#include <algorithm>
#include <iostream>
#include <vector>
#include "screen.h"

using namespace std;

int main(int argc, char* argv[]) {

  string inp;
  rapidjson::Document d;
  getline(cin, inp);

  d.Parse<0>(inp.c_str());
  screen *s = process_screen(d["screen"]);

  vector<string> results, universe = get_universe(argv, 2);
  s->set_universe(universe);
  results = s->eval(date(argv[1]));

  for(int i = 0; i < results.size(); i++) {
    cout << results[i] << endl;
  }
}
