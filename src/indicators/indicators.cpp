#include "indicators.h"
#include <ta_libc.h>
#include <algorithm>
#include <iostream>
#include <cmath>

indicators::indicators() {
  init_fntable();
  init_lookback_table();
}

float indicators::eval_indicator(std::string indicator, std::vector<float> args, pdata* data) {
  arglist = args;
  current_prices = data;
  return (this->*fn_table[indicator])();
}

float indicators::abs_value() {
  return abs(arglist[0]);
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

float indicators::max_open() {
  return internal_maxval(current_prices->open, (int)arglist[0]);
}

float indicators::max_high() {
  return internal_maxval(current_prices->high, (int)arglist[0]);
}

float indicators::max_low() {
  return internal_maxval(current_prices->low, (int)arglist[0]);
}

float indicators::max_close() {
  return internal_maxval(current_prices->close, (int)arglist[0]);
}

float indicators::max_volume() {
}

float indicators::min_open() {
  return internal_minval(current_prices->open, (int)arglist[0]);
}

float indicators::min_high() {
  return internal_minval(current_prices->high, (int)arglist[0]);
}

float indicators::min_low() {
  return internal_minval(current_prices->low, (int)arglist[0]);
}

float indicators::min_close() {
  return internal_minval(current_prices->close, (int)arglist[0]);
}

float indicators::min_volume() {
  //return internal_minval(current_prices->volume, (int)arglist[0]);
}

float indicators::internal_minval(std::vector<float> series, int size) {
  std::vector<float>::iterator result;
  result = std::min_element(series.begin(), series.end());
  int offset = std::distance(series.begin(), result);
  return series[offset];
}

float indicators::internal_maxval(std::vector<float> series, int size) {
  std::vector<float>::iterator result;
  result = std::max_element(series.begin(), series.end());
  int offset = std::distance(series.begin(), result);
  return series[offset];
}

float indicators::avgc() {
  return sma(current_prices->close);
}

float indicators::avgo() {
  return sma(current_prices->open);
}

float indicators::avgh() {
  return sma(current_prices->high);
}

float indicators::avgl() {
  return sma(current_prices->low);
}

float indicators::avgv() {
  return sma(current_prices->volume_as_floats());
}

float indicators::sma(vector<float> prices) {
  float* vals = &(*prices.begin());
  int start, count;
  double rval;

  TA_S_SMA(0, arglist[0] - 1, vals, arglist[0], &start, &count, &rval);
  return (float) rval;
}

float indicators::eavgc() {
  return eavg(current_prices->close);
}

float indicators::eavgo() {
  return eavg(current_prices->open);
}

float indicators::eavgh() {
  return eavg(current_prices->high);
}

float indicators::eavgl() {
  return eavg(current_prices->low);
}

float indicators::eavgv() {
  return eavg(current_prices->volume_as_floats());
}

float indicators::eavg(vector<float> data) {
  vector<float> prices = data;
  std::reverse(prices.begin(), prices.end());
  float* vals = &(*prices.begin());

  double rval[OUTPUT_BUFSIZE];
  int lookback = ema_lookback();
  int start, count;

  TA_S_EMA(0, lookback - 1, vals, arglist[0], &start, &count, &rval[0]);
  return (float) rval[count - 1];
}

float indicators::wmac() {
  return wma(current_prices->close);
}

float indicators::wmao() {
  return wma(current_prices->open);
}

float indicators::wmah() {
  return wma(current_prices->high);
}

float indicators::wmal() {
  return wma(current_prices->low);
}

float indicators::wmav() {
  return wma(current_prices->volume_as_floats());
}

float indicators::wma(vector<float> data) {
  vector<float> prices = data;
  std::reverse(prices.begin(), prices.end());
  float* vals = &(*prices.begin());
  int start, count;
  double rval;

  TA_S_WMA(0, arglist[0] - 1, vals, arglist[0], &start, &count, &rval);
  return (float) rval;
}

float indicators::avg_true_range() {
  int period = avg_true_range_lookback() - 1;

  vector<float> closes = current_prices->close;
  vector<float> highs = current_prices->high;
  vector<float> lows = current_prices->low;

  std::reverse(closes.begin(), closes.end());
  std::reverse(highs.begin(), highs.end());
  std::reverse(lows.begin(), lows.end());

  float *c = &(*closes.begin());
  float *h = &(*highs.begin());
  float *l = &(*lows.begin());

  double rval;
  int ostart, onum;

  TA_S_ATR(0, period, h, l, c, period, &ostart, &onum, &rval);
  return (float) rval;
}

float indicators::natr() {
  int period = avg_true_range_lookback() - 1;

  vector<float> closes = current_prices->close;
  vector<float> highs = current_prices->high;
  vector<float> lows = current_prices->low;

  std::reverse(closes.begin(), closes.end());
  std::reverse(highs.begin(), highs.end());
  std::reverse(lows.begin(), lows.end());

  float *c = &(*closes.begin());
  float *h = &(*highs.begin());
  float *l = &(*lows.begin());

  double rval;
  int ostart, onum;

  TA_S_NATR(0, period, h, l, c, period, &ostart, &onum, &rval);
  return (float) rval;
}

float indicators::rsi() {
  int period = rsi_lookback() / 4;
  vector<float> closes = current_prices->close;
  std::reverse(closes.begin(), closes.end());
  float *c = &(*closes.begin());
  double rval[OUTPUT_BUFSIZE];
  int ostart, onum;

  TA_S_RSI(0, (period * 4) - 1, c, period, &ostart, &onum, &rval[0]);
  return (float) rval[onum - 1];
}

float indicators::obv() {
  vector<float> volumes = current_prices->volume_as_floats();
  vector<float> prices = current_prices->close;

  std::reverse(volumes.begin(), volumes.end());
  std::reverse(prices.begin(), prices.end());

  float *v = &(*volumes.begin());
  float *c = &(*prices.begin());
  double rval[OUTPUT_BUFSIZE];
  int num, start;

  TA_S_OBV(0, volumes.size() - 1, c, v, &start, &num, &rval[0]);
  return (float) rval[num - 1];
}

float indicators::roc() {
    int period = arglist[0];
    float close = current_prices->close[0];
    float prev = current_prices->close[period];
    return ((close - prev) / prev) * 100;
}

float indicators::bollinger_upper() {
  double upper, lower;
  bollinger_values(&upper, &lower);
  return (float) upper;
}

float indicators::bollinger_lower() {
  double upper, lower;
  bollinger_values(&upper, &lower);
  return (float) lower;
}

void indicators::bollinger_values(double *upper, double *lower) {

  vector<float> prices = current_prices->close;
  std::reverse(prices.begin(), prices.end());
  float* c = &(*prices.begin());
  
  int s, n, period = 20;
  double avg, devs = 2;

  if(arglist.size() > 0) {
    period = (int) arglist[0];
    devs = arglist[1];
  }

  TA_S_BBANDS(0, prices.size() - 1, c, period, devs, devs, TA_MAType_SMA, &s, &n, upper, &avg, lower); 
}
