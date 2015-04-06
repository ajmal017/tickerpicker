#include "stock.h"
#include <iostream>
#include <stdexcept>

stock::stock(string ticker) {
  data = new ptable(ticker);
  this->ticker = ticker;
}

void stock::onday(date d) {
  pulldate = &d;
  history.clear();
}

float stock::eval_indicator(string indicator, vector<float> args) {
  int pull_len = icore.eval_lookback(indicator, args);
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

  return icore.eval_indicator(indicator, args, &history);
}
