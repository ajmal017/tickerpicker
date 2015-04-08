#include "indicators.h"
#include <ta_libc.h>


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

int indicators::accl_lookback() {
  if(arglist.size() == 0) {
    return 21;
  } else {
    return arglist[0] + 1;
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

int indicators::aroon_osc_lookback() {
  if(arglist.size() == 0) {
    return TA_AROONOSC_Lookback(25) + 1;
  } else {
    return TA_AROONOSC_Lookback(arglist[0]) + 1;
  }
}
