#include "indicators.h"
#include <ta_libc.h>
#include <algorithm>
#include <iostream>
#include <cmath>

indicators::indicators() {
  if(lookback_table.size() == 0 && fn_table.size() == 0) {
    init_fntable();
    init_lookback_table();
  }
}

float indicators::eval_indicator(std::string indicator, std::vector<float> args, pdata* data) {
  arglist = args;
  current_prices = data;
  return (*fn_table[indicator])(this);
}

float indicators::abs_value(indicators* thisptr) {
  return abs(thisptr->arglist[0]);
}

float indicators::volume_at(indicators* thisptr) {
  if(thisptr->arglist.size() == 0) {
    return thisptr->current_prices->volume[0];
  } else {
    int idx = (int) thisptr->arglist[0];
    return thisptr->current_prices->volume[idx];
  }
}

float indicators::close_at(indicators* thisptr) {
  if(thisptr->arglist.size() == 0) {
    return thisptr->current_prices->close[0];
  } else {
    int idx = (int) thisptr->arglist[0];
    return thisptr->current_prices->close[idx];
  }
}

float indicators::open_at(indicators* thisptr) {
  if(thisptr->arglist.size() == 0) {
    return thisptr->current_prices->open[0];
  } else {
    int idx = (int) thisptr->arglist[0];
    return thisptr->current_prices->open[idx];
  }
}

float indicators::high_at(indicators* thisptr) {
  if(thisptr->arglist.size() == 0) {
    return thisptr->current_prices->high[0];
  } else {
    int idx = (int) thisptr->arglist[0];
    return thisptr->current_prices->high[idx];
  }
}

float indicators::low_at(indicators* thisptr) {
  if(thisptr->arglist.size() == 0) {
    return thisptr->current_prices->low[0];
  } else {
    int idx = (int) thisptr->arglist[0];
    return thisptr->current_prices->low[idx];
  }
}

float indicators::max_open(indicators* thisptr) {
  return indicators::internal_maxval(thisptr->current_prices->open, (int)thisptr->arglist[0]);
}

float indicators::max_high(indicators* thisptr) {
  return indicators::internal_maxval(thisptr->current_prices->high, (int)thisptr->arglist[0]);
}

float indicators::max_low(indicators* thisptr) {
  return indicators::internal_maxval(thisptr->current_prices->low, (int)thisptr->arglist[0]);
}

float indicators::max_close(indicators* thisptr) {
  return indicators::internal_maxval(thisptr->current_prices->close, (int)thisptr->arglist[0]);
}

float indicators::max_volume(indicators* thisptr) {
}

float indicators::min_open(indicators* thisptr) {
  return indicators::internal_minval(thisptr->current_prices->open, (int)thisptr->arglist[0]);
}

float indicators::min_high(indicators* thisptr) {
  return indicators::internal_minval(thisptr->current_prices->high, (int)thisptr->arglist[0]);
}

float indicators::min_low(indicators* thisptr) {
  return indicators::internal_minval(thisptr->current_prices->low, (int)thisptr->arglist[0]);
}

float indicators::min_close(indicators* thisptr) {
  return indicators::internal_minval(thisptr->current_prices->close, (int)thisptr->arglist[0]);
}

float indicators::min_volume(indicators* thisptr) {
  //return internal_minval(thisptr->current_prices->volume, (int)thisptr->arglist[0]);
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

float indicators::avgc(indicators* thisptr) {
  return indicators::sma(thisptr, thisptr->current_prices->close);
}

float indicators::avgo(indicators* thisptr) {
  return indicators::sma(thisptr, thisptr->current_prices->open);
}

float indicators::avgh(indicators* thisptr) {
  return indicators::sma(thisptr, thisptr->current_prices->high);
}

float indicators::avgl(indicators* thisptr) {
  return indicators::sma(thisptr, thisptr->current_prices->low);
}

float indicators::avgv(indicators* thisptr) {
  return indicators::sma(thisptr, thisptr->current_prices->volume_as_floats());
}

float indicators::sma(indicators* thisptr, vector<float> prices) {
  float* vals = &(*prices.begin());
  int start, count;
  double rval;

  TA_S_SMA(0, thisptr->arglist[0] - 1, vals, thisptr->arglist[0], &start, &count, &rval);
  return (float) rval;
}

float indicators::eavgc(indicators* thisptr) {
  return indicators::eavg(thisptr, thisptr->current_prices->close);
}

float indicators::eavgo(indicators* thisptr) {
  return indicators::eavg(thisptr, thisptr->current_prices->open);
}

float indicators::eavgh(indicators* thisptr) {
  return indicators::eavg(thisptr, thisptr->current_prices->high);
}

float indicators::eavgl(indicators* thisptr) {
  return indicators::eavg(thisptr, thisptr->current_prices->low);
}

float indicators::eavgv(indicators* thisptr) {
  return indicators::eavg(thisptr, thisptr->current_prices->volume_as_floats());
}

float indicators::eavg(indicators* thisptr, vector<float> data) {
  vector<float> prices = data;
  std::reverse(prices.begin(), prices.end());
  float* vals = &(*prices.begin());

  double rval[OUTPUT_BUFSIZE];
  int lookback = indicators::ema_lookback(thisptr);
  int start, count;

  TA_S_EMA(0, lookback - 1, vals, thisptr->arglist[0], &start, &count, &rval[0]);
  return (float) rval[count - 1];
}

float indicators::wmac(indicators* thisptr) {
  return indicators::wma(thisptr, thisptr->current_prices->close);
}

float indicators::wmao(indicators* thisptr) {
  return indicators::wma(thisptr, thisptr->current_prices->open);
}

float indicators::wmah(indicators* thisptr) {
  return indicators::wma(thisptr, thisptr->current_prices->high);
}

float indicators::wmal(indicators* thisptr) {
  return indicators::wma(thisptr, thisptr->current_prices->low);
}

float indicators::wmav(indicators* thisptr) {
  return indicators::wma(thisptr, thisptr->current_prices->volume_as_floats());
}

float indicators::wma(indicators* thisptr, vector<float> data) {
  vector<float> prices = data;
  std::reverse(prices.begin(), prices.end());
  float* vals = &(*prices.begin());
  int start, count;
  double rval;

  TA_S_WMA(0, thisptr->arglist[0] - 1, vals, thisptr->arglist[0], &start, &count, &rval);
  return (float) rval;
}

float indicators::avg_true_range(indicators* thisptr) {
  int period = indicators::avg_true_range_lookback(thisptr) - 1;

  vector<float> closes = thisptr->current_prices->close;
  vector<float> highs = thisptr->current_prices->high;
  vector<float> lows = thisptr->current_prices->low;

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

float indicators::natr(indicators* thisptr) {
  int period = indicators::avg_true_range_lookback(thisptr) - 1;

  vector<float> closes = thisptr->current_prices->close;
  vector<float> highs = thisptr->current_prices->high;
  vector<float> lows = thisptr->current_prices->low;

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

float indicators::rsi(indicators* thisptr) {
  int period = indicators::rsi_lookback(thisptr) / 4;
  vector<float> closes = thisptr->current_prices->close;
  std::reverse(closes.begin(), closes.end());
  float *c = &(*closes.begin());
  double rval[OUTPUT_BUFSIZE];
  int ostart, onum;

  TA_S_RSI(0, (period * 4) - 1, c, period, &ostart, &onum, &rval[0]);
  return (float) rval[onum - 1];
}

float indicators::obv(indicators* thisptr) {
  vector<float> volumes = thisptr->current_prices->volume_as_floats();
  vector<float> prices = thisptr->current_prices->close;

  std::reverse(volumes.begin(), volumes.end());
  std::reverse(prices.begin(), prices.end());

  float *v = &(*volumes.begin());
  float *c = &(*prices.begin());
  double rval[OUTPUT_BUFSIZE];
  int num, start;

  TA_S_OBV(0, volumes.size() - 1, c, v, &start, &num, &rval[0]);
  return (float) rval[num - 1];
}

float indicators::roc(indicators* thisptr) {
    int period = thisptr->arglist[0];
    float close = thisptr->current_prices->close[0];
    float prev = thisptr->current_prices->close[period];
    return ((close - prev) / prev) * 100;
}

float indicators::bollinger_upper(indicators* thisptr) {
  double upper, lower;
  bollinger_values(thisptr, &upper, &lower);
  return (float) upper;
}

float indicators::bollinger_lower(indicators* thisptr) {
  double upper, lower;
  bollinger_values(thisptr, &upper, &lower);
  return (float) lower;
}

void indicators::bollinger_values(indicators* thisptr, double *upper, double *lower) {

  vector<float> prices = thisptr->current_prices->close;
  std::reverse(prices.begin(), prices.end());
  float* c = &(*prices.begin());
  
  int s, n, period = 20;
  double avg, devs = 2;

  if(thisptr->arglist.size() > 0) {
    period = (int) thisptr->arglist[0];
    devs = thisptr->arglist[1];
  }

  TA_S_BBANDS(0, prices.size() - 1, c, period, devs, devs, TA_MAType_SMA, &s, &n, upper, &avg, lower); 
}

float indicators::accl_upper(indicators* thisptr) {
  float upper, lower;
  acceleration_bands(thisptr, &upper, &lower);
  return upper;
}

float indicators::accl_lower(indicators* thisptr) {
  float upper, lower;
  acceleration_bands(thisptr, &upper, &lower);
  return lower;
}

void indicators::acceleration_bands(indicators* thisptr, float *upper, float *lower) {

  int period = thisptr->current_prices->size() - 1;
  float lowersum = 0, uppersum = 0;
  float factor = 0.001;

  if(thisptr->arglist.size() > 1) {
    factor = thisptr->arglist[1];
  }

  for(int i = 0; i < period; i++) {
    float low = thisptr->current_prices->low[i];
    float high = thisptr->current_prices->high[i];
    uppersum += ((high * (1 + 2 * (((high - low)/((high + low) /2)) * 1000) * factor)));
    lowersum += ((low * (1 - 2 * (((high - low) / ((high + low) / 2)) * 1000) * factor)));
  }

  *upper = uppersum / period;
  *lower = lowersum / period;
}

float indicators::aroon_osc(indicators* thisptr) {
  int period = indicators::aroon_osc_lookback(thisptr) - 1;

  vector<float> highs = thisptr->current_prices->high;
  vector<float> lows = thisptr->current_prices->low;

  std::reverse(highs.begin(), highs.end());
  std::reverse(lows.begin(), lows.end());

  float *h = &(*highs.begin());
  float *l = &(*lows.begin());

  double rval;
  int ostart, onum;

  TA_S_AROONOSC(0, period, h, l, period, &ostart, &onum, &rval);
  return (float) rval;
}
