#ifndef EVALUATOR
#define EVALUATOR
#include <vector>
#include <string>
#include "stock.h"
#include <map>

using namespace std;

class ruleset {
  public:

  ruleset(vector<string>, vector<string>);
  bool eval(stock);

  private:

  enum operation {FN, VAL, EQU, ADD, SUB, MUL, DIV, AND, OR, XOR, GT, LT, GTE, LTE, TERNARY};

  struct symbol {
    int rval;
    int lval;
    int tbranch;
    string indicator;
    ruleset::operation op;
  };

  struct svalue {
    bool bval;
    float nval;
    bool evaled;
  };

  bool is_number(const string&); 
  symbol parse_rule(string);
  void reset_scratchpad();
  void init_opmap();
  void eval_fn(int);
  void eval_ternary(int);
  void eval_symbol(int);
  void eval_op(operation, svalue*, svalue*, svalue*);

  stock* current_stock;
  vector<symbol> rules;
  vector<symbol> table;
  vector<svalue*> scratch; 
  map<string, ruleset::operation> opmap;
};

#endif
