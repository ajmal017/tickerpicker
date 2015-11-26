#ifndef STOCK
#define STOCK
#include "indicators.h"
#include "dividends.h"
#include "ptable.h"
#include "date.h"

class stock {

  public:
    stock(string);
    void onday(date);
    float eval_indicator(string, vector<float>, int offset=0);

  private:

    void clear_history();
    void pull_history(int);
    void concat_history(pdata);

    static std::map<string, ptable*> alldata; 

    indicators icore;
    date* pulldate;
    string ticker;
    pdata history;
    ptable *data;
};

#endif
