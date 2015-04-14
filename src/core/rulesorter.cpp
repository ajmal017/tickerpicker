/* Class for sorting rulesets.  This is an important optimization for
 * the overall speed of the screening (and by extension, backtesting)
 * process.  Rules are sorted in ascending order by their lookback periods,
 * so that rules requiring the least amount of data are evaluated first,
 * allowing short circuit evaluation with respect to slow and expensive
 * external I/O operations.  Since this process also involves an evaluation
 * of rules, both this class and the ruleset are descendants of a generic
 * symbol table.  In this case, the ruleset is evaluated exactly once, at
 * startup.  A recursive walk of the rules populates the symbol table with
 * the lookback period for each symbol, and expressions are given the larger
 * value of the lookbacks for the lvalue and rvalue.  This continues up the
 * tree until each rule receives it's lookback value, the largest lookback
 * for any of the subexpressions it consists of.  The rules are then sorted
 * by their lookback periods.
 */

#include "indicators.h"
#include "ruleset.h"
#include <algorithm>
#include <iostream>
#include <cstdlib>

ruleset_sort::ruleset_sort(vector<symbol> rules, vector<symbol> table, vector<string> raw) {
  rawsymbols = raw;
  this->rules = rules;
  this->table = table;
}

vector<symbol_table::symbol> ruleset_sort::sorted_rules() {
  vector<pair<int, symbol> > periods;
  vector<symbol> rval;

  for(int i = 0; i < rules.size(); i++) {
    int period = greater_value(rules[i]);  
    pair<int, symbol> p = make_pair(period, rules[i]);
    periods.push_back(p);
  }

  sort(periods.begin(), periods.end(), sort_pred());

  for(int i = 0; i < periods.size(); i++) {
    rval.push_back(periods[i].second);
  }

  return rval;
}

int ruleset_sort::lookback_for(symbol cur) {

  //a constant needs no lookback
  if(cur.op == VAL) {
    return 0;
  }

  if(cur.op == FN) {
    return function_value(cur);
  }

  if(cur.op == SHIFT) {
    symbol arg = table[cur.arglist[1]];
    symbol look = table[cur.arglist[0]];
    return lookback_for(arg) + look.value;
  }

  //if we're here, then we're dealing
  //with one of the arithmetic or logical ops
  return greater_value(cur);
}

int ruleset_sort::greater_value(symbol cur) {
  symbol lval = table[cur.lval];
  symbol rval = table[cur.rval];
  int lperiod = lookback_for(lval);
  int rperiod = lookback_for(rval);
  return (lperiod > rperiod ? lperiod : rperiod);
}

int ruleset_sort::function_value(symbol fn) {
  vector<float> argvals;
  int maxarg = 0;
  float nval;

  for(int i = 0; i < fn.arglist.size(); i++) {
    int argidx = fn.arglist[i];
    symbol arg = table[argidx];
    int lb = lookback_for(arg);
    argvals.push_back(arg.value);
    maxarg = (lb > maxarg ? lb : maxarg);
  }

  indicators i;
  int fnlook = i.eval_lookback(fn.indicator, argvals);
  return (fnlook > maxarg ? fnlook : maxarg);
}
