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

float stock::eval_indicator(string indicator) {
  history = data->pull_history_by_limit(*pulldate, 3);

  if(history.close.size() < 3) {
    throw std::out_of_range("insufficient data");
  }

  return history.close[0];
}
