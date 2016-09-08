/*
* As you look at this, you may be asking yourself, "why the Perl style thisptr
* being passed everywhere?"  The reason is that profiling revealed a hotspot
* in the table initialization code for the indicator class, which was spending
* about 20% of the runtime just building new copies of the lookukp tables.  So
* the lookup tables were changed to static members, which meant that the members
* they pointed to had to be static too.  The easiest way to have all static 
* indicator functions and still access per-object data was to just...pass a pointer
* around...
*/


#include "indicators.h"
#include <ta_libc.h>
#include <algorithm>
#include <iostream>

portfolio_metric* indicators::fn_portfolio;
position_metric* indicators::fn_position;

indicators::indicators() {
  if(lookback_table.size() == 0 && fn_table.size() == 0) {
    init_fntable();
    init_lookback_table();
  }
}

void indicators::set_portfolio(portfolio_metric* p) {
  fn_portfolio = p;
}

void indicators::set_position(position_metric *p) {
  fn_position = p;
}

float indicators::eval_indicator(std::string indicator, std::vector<float> args, pdata* data, int offset) {
  arglist = args;
  this->offset = offset;
  current_prices = data;
  return (*fn_table[indicator])(this);
}

float indicators::volume_at(indicators* thisptr) {
  if(thisptr->arglist.size() == 0) {
    return thisptr->current_prices->volume[thisptr->offset];
  } else {
    int idx = (int) thisptr->arglist[0];
    return thisptr->current_prices->volume[idx + thisptr->offset];
  }
}

float indicators::close_at(indicators* thisptr) {
  if(thisptr->arglist.size() == 0) {
    return thisptr->current_prices->close[thisptr->offset];
  } else {
    int idx = (int) thisptr->arglist[0];
    return thisptr->current_prices->close[idx + thisptr->offset];
  }
}

float indicators::open_at(indicators* thisptr) {
  if(thisptr->arglist.size() == 0) {
    return thisptr->current_prices->open[thisptr->offset];
  } else {
    int idx = (int) thisptr->arglist[0];
    return thisptr->current_prices->open[idx + thisptr->offset];
  }
}

float indicators::high_at(indicators* thisptr) {
  if(thisptr->arglist.size() == 0) {
    return thisptr->current_prices->high[thisptr->offset];
  } else {
    int idx = (int) thisptr->arglist[0];
    return thisptr->current_prices->high[idx + thisptr->offset];
  }
}

float indicators::low_at(indicators* thisptr) {
  if(thisptr->arglist.size() == 0) {
    return thisptr->current_prices->low[thisptr->offset];
  } else {
    int idx = (int) thisptr->arglist[0];
    return thisptr->current_prices->low[idx + thisptr->offset];
  }
}

float indicators::date_at(indicators* thisptr) {
  if(thisptr->arglist.size() == 0) {
    return thisptr->current_prices->date[thisptr->offset];
  } else {
    int idx = (int) thisptr->arglist[0];
    return thisptr->current_prices->date[idx + thisptr->offset];
  }
}

float indicators::max_open(indicators* thisptr) {
  return indicators::internal_maxval(thisptr, thisptr->current_prices->open);
}

float indicators::max_high(indicators* thisptr) {
  return indicators::internal_maxval(thisptr, thisptr->current_prices->high);
}

float indicators::max_low(indicators* thisptr) {
  return indicators::internal_maxval(thisptr, thisptr->current_prices->low);
}

float indicators::max_close(indicators* thisptr) {
  return indicators::internal_maxval(thisptr, thisptr->current_prices->close);
}

float indicators::max_volume(indicators* thisptr) {
  std::vector<uint32_t>::iterator result;
  std::vector<uint32_t>::iterator start = thisptr->current_prices->volume.begin() + thisptr->offset;
  std::vector<uint32_t>::iterator end = start + thisptr->arglist[0] + 1;
  result = std::max_element(start, end);
  int offset = std::distance(start, result);
  return thisptr->current_prices->volume[thisptr->offset + offset];
}

float indicators::min_open(indicators* thisptr) {
  return indicators::internal_minval(thisptr, thisptr->current_prices->open);
}

float indicators::min_high(indicators* thisptr) {
  return indicators::internal_minval(thisptr, thisptr->current_prices->high);
}

float indicators::min_low(indicators* thisptr) {
  return indicators::internal_minval(thisptr, thisptr->current_prices->low);
}

float indicators::min_close(indicators* thisptr) {
  return indicators::internal_minval(thisptr, thisptr->current_prices->close);
}

float indicators::min_volume(indicators* thisptr) {
  std::vector<uint32_t>::iterator result;
  std::vector<uint32_t>::iterator start = thisptr->current_prices->volume.begin() + thisptr->offset;
  std::vector<uint32_t>::iterator end = start + thisptr->arglist[0] + 1;
  result = std::min_element(start, end);
  int offset = std::distance(start, result);
  return thisptr->current_prices->volume[thisptr->offset + offset];
}

float indicators::internal_minval(indicators* thisptr, std::vector<float> series) {
  std::vector<float>::iterator result;
  std::vector<float>::iterator start = series.begin() + thisptr->offset;
  std::vector<float>::iterator end = start + thisptr->arglist[0] + 1;
  result = std::min_element(start, end);
  int offset = std::distance(start, result);
  return series[thisptr->offset + offset];
}

float indicators::internal_maxval(indicators* thisptr, std::vector<float> series) {
  std::vector<float>::iterator result;
  std::vector<float>::iterator start = series.begin() + thisptr->offset;
  std::vector<float>::iterator end = start + thisptr->arglist[0] + 1;
  result = std::max_element(start, end);
  int offset = std::distance(start, result);
  return series[thisptr->offset + offset];
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
  double rval[OUTPUT_BUFSIZE];
  int start, count;

  TA_S_SMA(0, prices.size() - 1, vals, thisptr->arglist[0], &start, &count, &rval[0]);
  return (float) rval[thisptr->offset];
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

  TA_S_EMA(0, data.size() - 1, vals, thisptr->arglist[0], &start, &count, &rval[0]);
  return (float) rval[count - thisptr->offset - 1];
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
  double rval[OUTPUT_BUFSIZE];
  int start, count;

  TA_S_WMA(0, data.size() - 1, vals, thisptr->arglist[0], &start, &count, &rval[0]);
  return (float) rval[count - thisptr->offset - 1];
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

  double rval[OUTPUT_BUFSIZE];
  int ostart, onum;

  TA_S_ATR(0, closes.size() - 1, h, l, c, period, &ostart, &onum, &rval[0]);
  return (float) rval[onum - thisptr->offset - 1];
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

  double rval[OUTPUT_BUFSIZE];
  int ostart, onum;

  TA_S_NATR(0, closes.size() - 1, h, l, c, period, &ostart, &onum, &rval[0]);
  return (float) rval[onum - thisptr->offset - 1];
}

float indicators::rsi(indicators* thisptr) {
  int period = indicators::rsi_lookback(thisptr) / 4;
  vector<float> closes = thisptr->current_prices->close;
  std::reverse(closes.begin(), closes.end());
  float *c = &(*closes.begin());
  double rval[OUTPUT_BUFSIZE];
  int ostart, onum;

  TA_S_RSI(0, closes.size() - 1, c, period, &ostart, &onum, &rval[0]);
  return (float) rval[onum - thisptr->offset - 1];
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
    int period = (thisptr->arglist.size() > 0 ? thisptr->arglist[0] : 12);
    float close = thisptr->current_prices->close[thisptr->offset];
    float prev = thisptr->current_prices->close[thisptr->offset + period];
    return ((close - prev) / prev) * 100;
}

float indicators::bollinger_upper(indicators* thisptr) {
  double upper[OUTPUT_BUFSIZE], lower[OUTPUT_BUFSIZE];
  int last;

  bollinger_values(thisptr, &upper[0], &lower[0], &last);
  return (float) upper[last - thisptr->offset - 1];
}

float indicators::bollinger_lower(indicators* thisptr) {
  double upper[OUTPUT_BUFSIZE], lower[OUTPUT_BUFSIZE];
  int last;

  bollinger_values(thisptr, &upper[0], &lower[0], &last);
  return (float) lower[last - thisptr->offset - 1];
}

void indicators::bollinger_values(indicators* thisptr, double *upper, double *lower, int *count) {

  vector<float> prices = thisptr->current_prices->close;
  std::reverse(prices.begin(), prices.end());
  float* c = &(*prices.begin());
  
  int s, period = 20;
  double avg[OUTPUT_BUFSIZE], devs = 2;

  if(thisptr->arglist.size() > 0) {
    period = (int) thisptr->arglist[0];
    devs = thisptr->arglist[1];
  }

  TA_S_BBANDS(0, prices.size() - 1, c, period, devs, devs, TA_MAType_SMA, &s, count, upper, &avg[0], lower); 
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

  int period = indicators::accl_lookback(thisptr) - 1;
  float lowersum = 0, uppersum = 0;
  float factor = 0.001;

  if(thisptr->arglist.size() > 1) {
    factor = thisptr->arglist[1];
  }

  for(int i = thisptr->offset; i < thisptr->offset + period; i++) {
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

  double rval[OUTPUT_BUFSIZE];
  int ostart, onum;

  TA_S_AROONOSC(0, highs.size() - 1, h, l, period, &ostart, &onum, &rval[0]);
  return (float) rval[onum - thisptr->offset - 1];
}

float indicators::data_age(indicators* thisptr) {
  return thisptr->current_prices->offset;
}
