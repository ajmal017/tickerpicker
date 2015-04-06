#ifndef SCREEN
#define SCREEN
#include <vector>
#include <string>
#include "ruleset.h"
#include "date.h"
#include <map>

class screen {

  public:

  screen(vector<string>, vector<string>);
  void set_universe(vector<string>);
  vector<string> eval(date);

  private:

  ruleset* srules;
  vector<string> universe;
  static map<string, stock> all;

};

#endif
