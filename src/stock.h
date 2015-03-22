#ifndef STOCK
#define STOCK
#include "ptable.h"
#include "date.h"

class stock {

  public:
    stock(string);
    void onday(date);
    float eval_indicator(string);

  private:

    date* pulldate;
    string ticker;
    pdata history;
    ptable *data;
};

#endif
