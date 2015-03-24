#include "stock.h"
#include <iostream>
#include <stdexcept>

stock::stock(string ticker) {
  data = new ptable(ticker);
  this->ticker = ticker;
}

void stock::onday(date d) {
  pulldate = &d;
}

float stock::eval_indicator(string indicator, vector<float> args) {
  int pull_len = icore.eval_lookback(indicator, args);
  history = data->pull_history_by_limit(*pulldate, pull_len);

  if(history.close.size() < pull_len) {
    throw std::out_of_range("insufficient data");
  }

  return icore.eval_indicator(indicator, args, &history);
}
