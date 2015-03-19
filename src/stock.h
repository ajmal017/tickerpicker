#ifndef STOCK
#define STOCK
#include "date.h"

class stock {

  public:
    stock(string);
    float eval_indicator(string, ...);
};

#endif
