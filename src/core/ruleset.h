#ifndef EVALUATOR
#define EVALUATOR
#include <cstdlib>
#include <vector>
#include <string>
#include "stock.h"
#include <map>

#include <iostream>

#define EPSILON 0.001

using namespace std;

class expression {
  public:
    virtual float eval(stock, int x = 0) = 0;
    virtual int lookback() = 0;
    float value() { return 0; }
  protected:
    vector<string> split(string, char s=' ');
    int index(string);
};

class rule : public expression {
  public:
    enum operation {EQU, AND, OR, XOR, GT, LT, GTE, LTE};
    rule(string, vector<expression*>);
    float eval(stock, int sh = 0);
    int lookback();
  private:
    expression *rvalue;
    expression *lvalue;
    operation op;
};

class constant : public expression {
  public:
    constant(string v) {val = (float) std::atof(v.c_str());}
    float eval(stock, int) {return val;}
    float value() { return val; }
    int lookback() {return 0;}
  private:
    float val;
};

class shift : public expression {
  public:
    shift(string, vector<expression*>);
    int lookback();
    float eval(stock, int);
  private:
    int shiftval;
    expression *context;
};

class term : public expression {
  public:
    enum operation {ADD, SUB, MUL, DIV};
    term(string, vector<expression*>);
    int lookback();
    float eval(stock, int);
  private:
    expression *rvalue;
    expression *lvalue;
    operation op;
};

class ternary : public expression {
  public:
    ternary(string, vector<expression*>);
    int lookback();
    float eval(stock, int);
  private:
    expression* decision;
    expression* truebranch;
    expression* falsebranch;  
};

class function : public expression {
  public:
    function(string, vector<expression*>);
    int lookback();
    float eval(stock, int);
  private:
    vector<expression*> arglist;
    stock *current;
    string indicator;
};

class ruleset {
  public:
    ruleset(vector<string>, vector<string>);
    bool eval(stock);
  private:
    bool is_rule(const string&); 
    bool is_shift(const string&);
    bool is_number(const string&); 
    bool is_ternary(const string&); 
    bool is_expression(const string&); 
    void sort_ruleset();

    vector<rule*> rules;

  struct sort_pred {
    bool operator()(const std::pair<int, rule*> &left, const std::pair<int, rule*> &right) {
      return left.first < right.first;
    }
  };
};

#endif
