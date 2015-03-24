#ifndef STOCK
#define STOCK
#include "indicators.h"
#include "ptable.h"
#include "date.h"

class stock {

  public:
    stock(string);
    void onday(date);
    float eval_indicator(string, vector<float>);

  private:

    indicators icore;
    date* pulldate;
    string ticker;
    pdata history;
    ptable *data;
};

#endif
