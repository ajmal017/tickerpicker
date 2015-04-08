/* This is the class that ultimately evaluates the expressions given to the
 * screener and backtester.  Rules are passed in via the constructor and 
 * parsed into an internal representation.  The evaluation consists of
 * performing a recursive walk of the three address code, which is stored 
 * in two tables: rules, which has the code for the top level boolean rule 
 * statements, and table, which is the table of subexpressions and constants 
 * that the lvalue and rvalue of a rule reference.  Each side of the rule is 
 * recursively evaluated down to constants, and values for the expressions 
 * computed and stored in the scratch table.  The svalue structs in the scratch 
 * table also have a flag to prevent repeated evaluation of a single subexpression, 
 * which effectively caches potentially expensive indicator functions. Constants 
 * are just added to the scratch table, indicators are called on the current stock, 
 * and their values added to the scratch table, and expressions are evaluated
 * in eval_op, and their result added to the scratch table.  Once the evaluation
 * is complete, the scratch table entries for the boolean lvalue and rvalue of 
 * each rule are populated, and the rule is evaluated to yield true or false.
 */

#include "ruleset.h"
#include <string>
#include <cstdlib>
#include <iostream>
#include <sstream>
#include <math.h>

ruleset::ruleset(vector<string> rules, vector<string> symbols) {
  init_opmap();

  for(int i = 0; i < rules.size(); i++) {
    symbol s = parse_rule(rules[i]);
    this->rules.push_back(s);
    scratch.pop_back();
  }

  for(int i = 0; i < symbols.size(); i++) {
    symbol s = parse_rule(symbols[i]);
    table.push_back(s);
  }

  ruleset_sort ssort(this->rules, table, symbols);
  this->rules = ssort.sorted_rules(); 
}

void ruleset::reset_scratchpad() {
  for(int i = 0; i < scratch.size(); i++) {
    scratch[i]->evaled = false;
  }
}

bool ruleset::eval(stock s) {
  reset_scratchpad();
  current_stock = &s;
  for(int i = 0; i < rules.size(); i++) {
    symbol rule = rules[i];

    try {
      eval_symbol(rule.lval);
      eval_symbol(rule.rval);
    } catch(exception &e) {
      return false;
    }

    svalue result;
    eval_op(rule.op, scratch[rule.lval], scratch[rule.rval], &result);

    if(!result.bval) {
      return false;
    }
  }

  return true;
}

void ruleset::eval_symbol(int symidx) {
  ruleset::symbol sym = table[symidx];
  ruleset::svalue* cur = scratch[symidx];

  if(cur->evaled || sym.op == VAL) {
    return;
  }

  if(sym.op == FN) {
    eval_fn(symidx);
    return;
  }

  if(sym.op == TERNARY) {
    eval_ternary(symidx);
    return;
  }

  eval_symbol(sym.lval);
  eval_symbol(sym.rval);

  ruleset::svalue* rval = scratch[sym.rval];
  ruleset::svalue* lval = scratch[sym.lval];

  eval_op(sym.op, lval, rval, cur);
  cur->evaled = true;
}

void ruleset::eval_op(operation op, svalue* lval, svalue* rval, svalue* cur) {
  switch(op) {
    case ADD:
      cur->nval = lval->nval + rval->nval;
      break;
    case SUB:
      cur->nval = lval->nval - rval->nval;
      break;
    case MUL:
      cur->nval = lval->nval * rval->nval;
      break;
    case DIV:
      cur->nval = lval->nval / rval->nval;
      break;
    case EQU:
      cur->bval = (fabs(lval->nval - rval->nval) < EPSILON);
      break;
    case AND:
      cur->bval = lval->bval && rval->bval;
      break;
    case XOR:
      cur->bval = (lval->bval ? !rval->bval : rval->bval); 
      break;
    case OR:
      cur->bval = lval->bval || rval->bval;
      break;
    case GT:
      cur->bval = lval->nval > rval->nval;
      break;
    case LT:
      cur->bval = lval->nval < rval->nval;
      break;
    case GTE:
      cur->bval = lval->nval >= rval->nval;
      break;
    case LTE:
      cur->bval = lval->nval <= rval->nval;
      break;
  }
}

void ruleset::eval_ternary(int symidx) {
  ruleset::symbol sym = table[symidx];
  ruleset::svalue* cur = scratch[symidx];

  if(cur->evaled) {
    return;
  }

  eval_symbol(sym.tbranch);

  if(scratch[sym.tbranch]->bval) 
    eval_symbol(sym.lval);
  else
    eval_symbol(sym.rval);
}

void ruleset::eval_fn(int symidx) {
  ruleset::symbol sym = table[symidx];
  ruleset::svalue* cur = scratch[symidx];
  vector<float> args;

  for(int i = 0; i < sym.arglist.size(); i++) {
    int argidx = sym.arglist[i];
    eval_symbol(argidx);
    ruleset::svalue* arg = scratch[argidx];
    args.push_back(arg->nval);
  }

  cur->nval = current_stock->eval_indicator(sym.indicator, args);
  scratch[symidx]->evaled = true;
}

ruleset::symbol ruleset::parse_rule(string rule) {
  stringstream ss(rule);
  symbol current;
  string temp;

  svalue* val = new svalue; 

  ss >> temp;

  //lvalue first...
  if(temp.at(0) == '$') {
    temp.erase(0, 1);
    current.lval = atoi(temp.c_str());
  } else {

    if(is_number(temp)) {
      val->nval = (float) atof(temp.c_str());
      current.value = val->nval;
      current.op = VAL; 
    } else {
      current.indicator = temp;
      current.arglist = parse_arglist(rule);
      current.op = FN;
    }
    
    scratch.push_back(val);
    return current;
  }

  ss >> temp;

  //now let's see if op is a variable
  //or not...
  if(temp.at(0) == '$') {
    temp.erase(0, 1);
    current.op = TERNARY;
    current.tbranch = current.lval;
    current.lval = atoi(temp.c_str());
  } else {
    current.op = opmap[temp];
  }

  ss >> temp;
  temp.erase(0, 1);
  current.rval = atoi(temp.c_str());

  scratch.push_back(val);
  return current;
}

vector<int> ruleset::parse_arglist(string list) {

  string::size_type lastPos = list.find_first_not_of(",", 0);
  string::size_type pos = list.find_first_of(",", lastPos);
  vector<int> rval;

  while (string::npos != pos || string::npos != lastPos) {
    string arg = list.substr(lastPos, pos - lastPos);
    lastPos = list.find_first_not_of(",", pos);
    pos = list.find_first_of(",", lastPos);

    arg.erase(0, arg.find_first_of("$")+1);
    if(arg.size() > 0 && is_number(arg)) {
      int argindex = atoi(arg.c_str());
      rval.push_back(argindex);
    }
  }

  return rval;
}

void ruleset::init_opmap() {
  opmap["+"] = ADD;
  opmap["-"] = SUB;
  opmap["*"] = MUL;
  opmap["/"] = DIV;
  opmap["OR"] = OR;
  opmap["AND"] = AND;
  opmap["XOR"] = XOR;
  opmap["<="] = LTE;
  opmap[">="] = GTE;
  opmap["="] = EQU;
  opmap["<"] = LT;
  opmap[">"] = GT;
}

bool ruleset::is_number(const string& s) {
  return(s.find_first_not_of("-.0123456789") == string::npos);
}
