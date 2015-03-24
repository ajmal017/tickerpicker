#include "indicators.h"
#include <ta_libc.h>
#include <iostream>

indicators::indicators() {
  init_fntable();
  init_lookback_table();
}

void indicators::init_fntable() {
  fn_table["V"] = &indicators::volume_at;
  fn_table["C"] = &indicators::close_at;
  fn_table["O"] = &indicators::open_at;
  fn_table["H"] = &indicators::high_at;
  fn_table["L"] = &indicators::low_at;
}

void indicators::init_lookback_table() {
  lookback_table["O"] = &indicators::ohlcv_lookback;
  lookback_table["H"] = &indicators::ohlcv_lookback;
  lookback_table["L"] = &indicators::ohlcv_lookback;
  lookback_table["C"] = &indicators::ohlcv_lookback;
  lookback_table["V"] = &indicators::ohlcv_lookback;
}

int indicators::eval_lookback(std::string indicator, std::vector<float> args) {
  arglist = args;
  return (this->*lookback_table[indicator])();
}

int indicators::ohlcv_lookback() {
  if(arglist.size() == 0) {
    return 1;
  } else {
    return ((int) arglist[0]) + 1;
  }
}

float indicators::eval_indicator(std::string indicator, std::vector<float> args, pdata* data) {
  arglist = args;
  current_prices = data;
  return (this->*fn_table[indicator])();
}

float indicators::volume_at() {
  if(arglist.size() == 0) {
    return current_prices->volume[0];
  } else {
    int idx = (int) arglist[0];
    return current_prices->volume[idx];
  }
}

float indicators::close_at() {
  if(arglist.size() == 0) {
    return current_prices->close[0];
  } else {
    int idx = (int) arglist[0];
    return current_prices->close[idx];
  }
}

float indicators::open_at() {
  if(arglist.size() == 0) {
    return current_prices->open[0];
  } else {
    int idx = (int) arglist[0];
    return current_prices->open[idx];
  }
}

float indicators::high_at() {
  if(arglist.size() == 0) {
    return current_prices->high[0];
  } else {
    int idx = (int) arglist[0];
    return current_prices->high[idx];
  }
}

float indicators::low_at() {
  if(arglist.size() == 0) {
    return current_prices->low[0];
  } else {
    int idx = (int) arglist[0];
    return current_prices->low[idx];
  }
}
