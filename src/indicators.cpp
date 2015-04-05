#include "indicators.h"
#include <ta_libc.h>
#include <algorithm>
#include <iostream>
#include <cmath>

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

  fn_table["MAXO"] = &indicators::max_open;
  fn_table["MAXH"] = &indicators::max_high;
  fn_table["MAXL"] = &indicators::max_low;
  fn_table["MAXC"] = &indicators::max_close;
  fn_table["MAXV"] = &indicators::max_volume;

  fn_table["MINO"] = &indicators::min_open;
  fn_table["MINH"] = &indicators::min_high;
  fn_table["MINL"] = &indicators::min_low;
  fn_table["MINC"] = &indicators::min_close;
  fn_table["MINV"] = &indicators::min_volume;

  fn_table["AVGO"] = &indicators::avgo;
  fn_table["AVGH"] = &indicators::avgh;
  fn_table["AVGL"] = &indicators::avgl;
  fn_table["AVGC"] = &indicators::avgc;
  fn_table["AVGV"] = &indicators::avgv;

  fn_table["EMAO"] = &indicators::eavgo;
  fn_table["EMAH"] = &indicators::eavgh;
  fn_table["EMAL"] = &indicators::eavgl;
  fn_table["EMAC"] = &indicators::eavgc;
  fn_table["EMAV"] = &indicators::eavgv;

  fn_table["WMAC"] = &indicators::wmac;
  fn_table["WMAH"] = &indicators::wmah;
  fn_table["WMAL"] = &indicators::wmal;
  fn_table["WMAO"] = &indicators::wmao;
  fn_table["WMAV"] = &indicators::wmav;

  fn_table["ATR"] = &indicators::avg_true_range;
  fn_table["ABS"] = &indicators::abs_value;
  fn_table["ROC"] = &indicators::roc;
  fn_table["NATR"] = &indicators::natr;
  fn_table["RSI"] = &indicators::rsi;
  fn_table["OBV"] = &indicators::obv;

  fn_table["BOLLINGER_UPPER"] = &indicators::bollinger_upper;
  fn_table["BOLLINGER_LOWER"] = &indicators::bollinger_lower;
}

void indicators::init_lookback_table() {
  lookback_table["O"] = &indicators::ohlcv_lookback;
  lookback_table["H"] = &indicators::ohlcv_lookback;
  lookback_table["L"] = &indicators::ohlcv_lookback;
  lookback_table["C"] = &indicators::ohlcv_lookback;
  lookback_table["V"] = &indicators::ohlcv_lookback;

  lookback_table["MAXO"] = &indicators::identity_lookback;
  lookback_table["MAXH"] = &indicators::identity_lookback;
  lookback_table["MAXL"] = &indicators::identity_lookback;
  lookback_table["MAXC"] = &indicators::identity_lookback;
  lookback_table["MAXV"] = &indicators::identity_lookback;

  lookback_table["MINO"] = &indicators::identity_lookback;
  lookback_table["MINH"] = &indicators::identity_lookback;
  lookback_table["MINL"] = &indicators::identity_lookback;
  lookback_table["MINC"] = &indicators::identity_lookback;
  lookback_table["MINV"] = &indicators::identity_lookback;

  lookback_table["AVGO"] = &indicators::identity_lookback;
  lookback_table["AVGH"] = &indicators::identity_lookback;
  lookback_table["AVGL"] = &indicators::identity_lookback;
  lookback_table["AVGC"] = &indicators::identity_lookback;
  lookback_table["AVGV"] = &indicators::identity_lookback;

  lookback_table["EMAO"] = &indicators::ema_lookback;
  lookback_table["EMAH"] = &indicators::ema_lookback;
  lookback_table["EMAL"] = &indicators::ema_lookback;
  lookback_table["EMAC"] = &indicators::ema_lookback;
  lookback_table["EMAV"] = &indicators::ema_lookback;
  
  lookback_table["WMAC"] = &indicators::identity_lookback;
  lookback_table["WMAO"] = &indicators::identity_lookback;
  lookback_table["WMAH"] = &indicators::identity_lookback;
  lookback_table["WMAL"] = &indicators::identity_lookback;
  lookback_table["WMAV"] = &indicators::identity_lookback;

  lookback_table["ATR"] = &indicators::avg_true_range_lookback;
  lookback_table["ABS"] = &indicators::absval_lookback;
  lookback_table["ROC"] = &indicators::roc_lookback;
  lookback_table["RSI"] = &indicators::rsi_lookback;
  lookback_table["OBV"] = &indicators::obv_lookback;
  lookback_table["NATR"] = &indicators::natr_lookback;

  lookback_table["BOLLINGER_UPPER"] = &indicators::bollinger_lookback;
  lookback_table["BOLLINGER_LOWER"] = &indicators::bollinger_lookback;
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

int indicators::identity_lookback() {
  return ((int) arglist[0]);
}

int indicators::rsi_lookback() {
  if(arglist.size() == 0) {
    return TA_RSI_Lookback(14) * 4;
  } else {
    return TA_RSI_Lookback((int) arglist[0]) * 4;
  }
}

int indicators::ema_lookback() {
  return TA_EMA_Lookback((int) arglist[0]) * 4;
}

int indicators::absval_lookback() {
  return 0;
}

int indicators::avg_true_range_lookback() {
  if(arglist.size() == 0) {
    return TA_ATR_Lookback(14) + 1;
  } else {
    return TA_ATR_Lookback((int) arglist[0]) + 1;
  }
}

int indicators::natr_lookback() {
  if(arglist.size() == 0) {
    return TA_ATR_Lookback(14) + 1;
  } else {
    return TA_ATR_Lookback((int) arglist[0]) + 1;
  }
}

int indicators::obv_lookback() {
  return 1;
}

int indicators::roc_lookback() {
  if(arglist.size() == 0) {
    return 13;
  } else {
    return ((int) arglist[0]) + 1;
  }
}

int indicators::bollinger_lookback() {
  if(arglist.size() == 0) {
    return TA_BBANDS_Lookback(20, 2.0, 2.0, TA_MAType_SMA) + 1;
  } else {
    return TA_BBANDS_Lookback((int)arglist[0], arglist[1], arglist[1], TA_MAType_SMA) + 1;
  }
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
