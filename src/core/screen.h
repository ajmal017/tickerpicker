#ifndef SCREEN
#define SCREEN
#include <vector>
#include <string>
#include "ruleset.h"
#include "date.h"
#include <map>

class restrictor {
  public: 
  virtual bool skip_ticker(string) = 0;
};

class screen {

  public:

  screen(vector<string>, vector<string>);
  vector<string> eval(date d, restrictor* r=NULL);
  void set_sort_exp(vector<string>, bool);
  void set_universe(vector<string>);
  bool eval(date, string);

  private:

  vector<string> sort_set(vector<string>, date);

  bool sort_dflag;
  ruleset* srules;
  expression* sort;
  vector<string> universe;
  static map<string, stock> all;

  struct asc_pred {
      bool operator()(const std::pair<float, string> &left, const std::pair<float, string> &right) {
            return left.first < right.first;
       }
  };

  struct desc_pred {
      bool operator()(const std::pair<float, string> &left, const std::pair<float, string> &right) {
            return right.first < left.first;
       }
  };
};

#endif
