#include "stock.h"
#include <iostream>
#include <stdexcept>

std::map<string, ptable*> stock::alldata; 

stock::stock(string ticker) {
  this->ticker = ticker;
  if(alldata.count(ticker) == 0) {
    data = new ptable(ticker);
    alldata[ticker] = data;
  } else {
    data = alldata[ticker];
  }
}

void stock::onday(date d) {
  pulldate = &d;
  history.clear();
}

float stock::eval_indicator(string indicator, vector<float> args, int offset) {
  int pull_len = icore.eval_lookback(indicator, args) + offset;

  if(pull_len > 0) {
    pull_history(pull_len); 
  }

  return icore.eval_indicator(indicator, args, &history, offset);
}

void stock::pull_history(int pull_len) {

  int histlen = history.size();

  if(histlen == 0) {
    history = data->pull_history_by_limit(*pulldate, pull_len);

    if(!history.is_valid(*pulldate, pull_len)) {
      throw std::out_of_range("insufficient data");
    }

  } else {
    int pullsize = pull_len - histlen;

    if(pullsize > 0) {
      pdata temp = data->read(pullsize);
      history.concat_history(temp);
    }
  }

  if(history.has_gaps() || history.size() < pull_len) {
    throw std::out_of_range("insufficient data");
  }
}
