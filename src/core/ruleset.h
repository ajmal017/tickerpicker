#ifndef EVALUATOR
#define EVALUATOR
#include <vector>
#include <string>
#include "stock.h"
#include <map>

#define EPSILON 0.001

using namespace std;

class symbol_table {

  public:

  enum operation {SHIFT, FN, VAL, EQU, ADD, SUB, MUL, DIV, AND, OR, XOR, GT, LT, GTE, LTE, TERNARY};

  struct symbol {
    int rval;
    int lval;
    int tbranch;
    float value;
    string indicator;
    vector<int> arglist;
    symbol_table::operation op;
  };

  protected:

  vector<symbol> rules;
  vector<symbol> table;
  int data_offset;
};

class ruleset : symbol_table {
  public:

  ruleset(vector<string>, vector<string>);
  bool eval(stock);

  private:

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
  void eval_symbol(int);
  void eval_ternary(int);
  void shift_timeframe(int);
  vector<int> parse_arglist(string);
  void eval_op(operation, svalue*, svalue*, svalue*);

  stock* current_stock;
  vector<svalue*> scratch; 
  map<string, ruleset::operation> opmap;
};

class ruleset_sort : symbol_table {
  public:
  ruleset_sort(vector<symbol>, vector<symbol>, vector<string>);
  vector<symbol_table::symbol> sorted_rules();

  private:

  struct sort_pred {
    bool operator()(const std::pair<int, symbol> &left, const std::pair<int, symbol> &right) {
      return left.first < right.first;
    }
  };

  int lookback_for(symbol);
  int greater_value(symbol);
  int function_value(symbol);

  vector<string> rawsymbols;
};

#endif
