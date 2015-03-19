#include "ruleset.h"
#include <string>
#include <cstdlib>
#include <iostream>
#include <sstream>

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
}

void ruleset::reset_scratchpad() {
  for(int i = 0; i < scratch.size(); i++) {
    scratch[i].evaled = false;
  }
}

bool ruleset::eval(stock s) {
  reset_scratchpad();
  current_stock = &s;
  for(int i = 0; i < rules.size(); i++) {
    symbol rule = rules[i];

    eval_symbol(rule.lval);
    eval_symbol(rule.rval);

    svalue result;
    eval_op(rule.op, scratch[rule.lval], scratch[rule.rval], result);

    if(!result.bval) {
      return false;
    }
  }

  return true;
}

void ruleset::eval_symbol(int symidx) {
  ruleset::symbol sym = table[symidx];
  ruleset::svalue cur = scratch[symidx];

  if(cur.evaled || sym.op == VAL) {
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

  ruleset::svalue rval = scratch[sym.rval];
  ruleset::svalue lval = scratch[sym.lval];

  eval_op(sym.op, lval, rval, cur);
  cur.evaled = true;
}


void ruleset::eval_op(operation op, svalue lval, svalue rval, svalue cur) {
  switch(op) {
    case ADD:
      cur.nval = lval.nval + rval.nval;
      break;
    case SUB:
      cur.nval = lval.nval - rval.nval;
      break;
    case MUL:
      cur.nval = lval.nval * rval.nval;
      break;
    case DIV:
      cur.nval = lval.nval / rval.nval;
      break;
    case EQU:
      cur.bval = lval.nval == rval.nval;
      break;
    case AND:
      cur.bval = lval.bval && lval.bval;
      break;
    case XOR:
      cur.bval = lval.bval ^ rval.bval;
      break;
    case OR:
      cur.bval = lval.bval || rval.bval;
      break;
    case GT:
      cur.bval = lval.nval > rval.nval;
      break;
    case LT:
      cur.bval = lval.nval < rval.nval;
      break;
    case GTE:
      cur.bval = lval.nval >= rval.nval;
      break;
    case LTE:
      cur.bval = lval.nval <= rval.nval;
      break;
  }
}

void ruleset::eval_ternary(int symidx) {
  ruleset::symbol sym = table[symidx];
  ruleset::svalue cur = scratch[symidx];

  if(cur.evaled) {
    return;
  }

  eval_symbol(sym.tbranch);

  if(scratch[sym.tbranch].bval) 
    eval_symbol(sym.lval);
  else
    eval_symbol(sym.rval);
}

void ruleset::eval_fn(int symidx) {
  ruleset::symbol sym = table[symidx];
  ruleset::svalue cur = scratch[symidx];
  current_stock->eval_indicator(sym.indicator);
}

ruleset::symbol ruleset::parse_rule(string rule) {
  stringstream ss(rule);
  symbol current;
  string temp;
  svalue val;  

  ss >> temp;

  //lvalue first...
  if(temp.at(0) == '$') {
    temp.erase(0, 1);
    current.lval = atoi(temp.c_str());
  } else {

    if(is_number(temp)) {
      val.nval = (float) atof(temp.c_str());
      current.op = VAL; 
    } else {
      current.indicator = temp;
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
