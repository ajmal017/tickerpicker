#include "stock.h"
#include <iostream>
#include <stdexcept>

stock::stock(string ticker) {
  data = new ptable(ticker);
  this->ticker = ticker;
}

void stock::onday(date d) {
  pulldate = &d;
  clear_history();
}

float stock::eval_indicator(string indicator, vector<float> args) {
  int pull_len = icore.eval_lookback(indicator, args);
  int histlen = history.close.size();

  if(histlen == 0) {
    history = data->pull_history_by_limit(*pulldate, pull_len);
  } else {
    int pullsize = pull_len - histlen;
    pdata temp = data->read(pullsize);
    concat_history(temp);
  }

  if(history.close.size() < pull_len) {
    throw std::out_of_range("insufficient data");
  }

  return icore.eval_indicator(indicator, args, &history);
}

void stock::concat_history(pdata newdata) {
  history.low.insert(history.low.end(), newdata.low.begin(), newdata.low.end());
  history.open.insert(history.open.end(), newdata.open.begin(), newdata.open.end());
  history.high.insert(history.high.end(), newdata.high.begin(), newdata.high.end());
  history.close.insert(history.close.end(), newdata.close.begin(), newdata.close.end());
  history.volume.insert(history.volume.end(), newdata.volume.begin(), newdata.volume.end());
  history.date.insert(history.date.end(), newdata.date.begin(), newdata.date.end());
}

void stock::clear_history() {
  history.low.clear();
  history.open.clear();
  history.high.clear();
  history.close.clear();
  history.volume.clear();
  history.date.clear();
}
