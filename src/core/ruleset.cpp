/* This is the collection of classes that ultimately evaluates the expressions
 * given to the screener and backtester.  Rules are passed as three address code
 * into the ruleset class through the constructor, and parsed into a set of 
 * expression trees built up from classes that encapsulate each type of code 
 * (Interpeter design pattern). A table mapping the index references in the  
 * three adress code to pointers pointing to objects implementing those
 * codes is passed to each constructor. Lvalue and rvalue references are
 * populated using the pointers so that we dont have to parse things repeatedly,
 * and so that repeated subexpressions are not evaluated redundantly. Once the
 * parse trees are built the evaluation consists of looping through each rule,
 * and building up the value of the expression until we arrive at a true or false
 * for the rule as a whole.  Note that the expression class can also be used
 * independently of rules to evaluate numerical expressions. 
 */

#include "ruleset.h"
#include <algorithm>
#include <cstdlib>
#include <iostream>
#include <sstream>
#include <string>
#include <math.h>

expression* expression_parser::parse(vector<string> symbols) {
  vector<expression*> table;
  parse(symbols, &table);
  return table.back();
}

void expression_parser::parse(vector<string> symbols, vector<expression*>* table) {
  for(int i = 0; i < symbols.size(); i++) {
    string cur = symbols[i];

    if(is_number(cur)) {
      table->push_back(new constant(cur));
      continue;
    }

    if(is_expression(cur)) {
      table->push_back(new term(cur, *table));
      continue; 
    }   

    if(is_ternary(cur)) {
      table->push_back(new ternary(cur, *table));
      continue;
    }

    if(is_shift(cur)) {
      table->push_back(new shift(cur, *table));
      continue;
    }

    if(is_rule(cur)) {
      table->push_back(new rule(cur, *table));
      continue;
    }

    table->push_back(new function(cur, *table));
  }
}

bool expression_parser::is_number(const string& s) {
  return(s.find_first_not_of("-.0123456789") == string::npos);
}

bool expression_parser::is_expression(const string& e) {
  return(e.find_first_of("-+*/") != string::npos);
}

bool expression_parser::is_ternary(const string& t) {
  return t[0] == '$' && std::count(t.begin(), t.end(), '$') == 3;
}

bool expression_parser::is_rule(const string& r) {
  if(r.find(" AND ") != string::npos) { return true; }
  if(r.find(" XOR ") != string::npos) { return true; }
  if(r.find(" OR ") != string::npos) { return true; }
  if(r.find(" >= ") != string::npos) { return true; }
  if(r.find(" <= ") != string::npos) { return true; }
  if(r.find(" < ") != string::npos) { return true; }
  if(r.find(" > ") != string::npos) { return true; }
  if(r.find(" = ") != string::npos) { return true; }
  return false;
}

bool expression_parser::is_shift(const string& s) {
  return(s.find("DAYS_AGO") == 0);
}

ruleset::ruleset(vector<string> rules, vector<string> symbols) {
  vector<expression*> table;
  expression_parser::parse(symbols, &table);

  for(int i = 0; i < rules.size(); i++) {
    string raw = rules[i];
    this->rules.push_back(new rule(raw, table));
  }

  sort_ruleset();
}

bool ruleset::eval(stock s) {
  for(int i = 0; i < rules.size(); i++) {
    if(!rules[i]->eval(s)) {
      return false;
    }
  }

  return true;
}

void ruleset::sort_ruleset() {
  vector<pair<int, rule*> > periods;

  for(int i = 0; i < rules.size(); i++) {
    int period = rules[i]->lookback();
    pair<int, rule*> p = make_pair(period, rules[i]);
    periods.push_back(p);
  }

  std::sort(periods.begin(), periods.end(), sort_pred());
  rules.clear();

  for(int i = 0; i < periods.size(); i++) {
    rules.push_back(periods[i].second);
  }
}

int expression::index(string t) { 
  t.erase(0, 1);
  return atoi(t.c_str());
}

vector<string> expression::split(string e, char sep) {
  vector<string> rval;
  stringstream ss(e);
  string t;

  while(getline(ss, t, sep)) {
    rval.push_back(t);
  }

  return rval;
}

rule::rule(string t, vector<expression*> table) {
  vector<string> parts = split(t);
  int lindex = index(parts[0]);
  int rindex = index(parts[2]);  

  lvalue = table[lindex];
  rvalue = table[rindex];

  if(parts[1] == "=") { op = EQU; }
  if(parts[1] == "AND") { op = AND; }  
  if(parts[1] == "OR") { op = OR; }
  if(parts[1] == "XOR") { op = XOR; }
  if(parts[1] == ">") { op = GT; }
  if(parts[1] == "<") { op = LT; }
  if(parts[1] == ">=") { op = GTE; }
  if(parts[1] == "<=") { op = LTE; }
}

float rule::eval(stock s, int sh) {
  try {

    switch(op) {
      case EQU:
        return (fabs(lvalue->eval(s, sh) - rvalue->eval(s, sh)) < EPSILON);
      case GT:
        return lvalue->eval(s, sh) > rvalue->eval(s, sh);
      case LT:
        return lvalue->eval(s, sh) < rvalue->eval(s, sh);
      case GTE:
        return lvalue->eval(s, sh) >= rvalue->eval(s, sh);
      case LTE:
        return lvalue->eval(s, sh) <= rvalue->eval(s, sh);
      case AND:
        return lvalue->eval(s, sh) && rvalue->eval(s, sh);
      case XOR:
        return (lvalue->eval(s, sh) ? !rvalue->eval(s, sh) : rvalue->eval(s, sh));
      case OR:
        return lvalue->eval(s, sh) || rvalue->eval(s, sh);
    }

  } catch(exception &e) {
    return false;
  }
}

int rule::lookback() {
  int left = lvalue->lookback();
  int right = lvalue->lookback();
  return (left > right ? left : right);
}

shift::shift(string raw, vector<expression*> table) {
  vector<string> parts = split(raw);
  vector<string> args = split(parts[1], ',');  

  int cindex = index(args[1]);
  context = table[cindex];

  int sindex = index(args[0]);
  constant *v = (constant*) table[sindex];
  shiftval = v->value();
}

int shift::lookback() {
  return shiftval + context->lookback();
}

float shift::eval(stock s, int shiftval) {
  int totalshift = this->shiftval + shiftval;
  return context->eval(s, totalshift);
}

term::term(string t, vector<expression*> table) {
  vector<string> parts = split(t);
  int lindex = index(parts[0]);
  int rindex = index(parts[2]);  

  lvalue = table[lindex];
  rvalue = table[rindex];

  if(parts[1] == "+") { op = ADD; }
  if(parts[1] == "-") { op = SUB; }  
  if(parts[1] == "/") { op = DIV; }
  if(parts[1] == "*") { op = MUL; }
}

int term::lookback() {
  int left = lvalue->lookback();
  int right = lvalue->lookback();
  return (left > right ? left : right);
}

float term::eval(stock s, int sh = 0) {
  switch(op) {
    case ADD:
      return lvalue->eval(s, sh) + rvalue->eval(s, sh);
    case SUB:
      return lvalue->eval(s, sh) - rvalue->eval(s, sh);
    case MUL:
      return lvalue->eval(s, sh) * rvalue->eval(s, sh);
    case DIV:
      return lvalue->eval(s, sh) / rvalue->eval(s, sh);
  }
}

ternary::ternary(string t, vector<expression*> table) {
  vector<string> parts = split(t);
  decision = table[index(parts[0])];
  truebranch = table[index(parts[1])];
  falsebranch = table[index(parts[2])];
}

int ternary::lookback() {
  int ruleval = decision->lookback();
  int tvalue = truebranch->lookback();
  int fvalue = falsebranch->lookback();

  if(ruleval >= tvalue && ruleval >= fvalue) {
    return ruleval;
  }

  if(tvalue >= ruleval && tvalue >= fvalue) {
    return tvalue;
  }

  if(fvalue >= ruleval && fvalue >= tvalue) {
    return fvalue;
  }
}

float ternary::eval(stock s, int shift = 0) {
  return (decision->eval(s, shift) ? truebranch->eval(s, shift) : falsebranch->eval(s, shift));
}

function::function(string t, vector<expression*> table) {
  vector<string> parts = split(t);
  indicator = parts[0];

  if(parts.size() > 1) {
    vector<string> args = split(parts[1], ',');
    for(int i = 0; i < args.size(); i++) {
      int argindex = index(args[i]);
      arglist.push_back(table[argindex]); 
    }
  }
}

int function::lookback() {
  vector<float> argvals; 
  int maxval = 0;

  for(int i = 0; i < arglist.size(); i++) {
    expression *cur = arglist[i];
    int lb = cur->lookback();
    maxval = (lb > maxval ? lb : maxval);
    argvals.push_back(cur->value());
  }

  indicators i;
  int ilook = i.eval_lookback(indicator, argvals);
  return (ilook > maxval ? ilook : maxval);
}

float function::eval(stock s, int shift = 0) {
  vector<float> args;

  for(int i = 0; i < arglist.size(); i++) {
    args.push_back(arglist[i]->eval(s, shift));
  }

  return s.eval_indicator(indicator, args, shift);
}
