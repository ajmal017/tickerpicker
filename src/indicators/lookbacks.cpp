#include "indicators.h"
#include <ta_libc.h>

int indicators::eval_lookback(std::string indicator, std::vector<float> args) {
  arglist = args;
  return (*lookback_table[indicator])(this);
}

int indicators::null_lookback(indicators* thisptr) {
  return 0;
}

int indicators::ohlcv_lookback(indicators* thisptr) {
  if(thisptr->arglist.size() == 0) {
    return 1;
  } else {
    return ((int) thisptr->arglist[0]) + 1;
  }
}

int indicators::identity_lookback(indicators* thisptr) {
  return ((int) thisptr->arglist[0]);
}

int indicators::minimax_lookback(indicators* thisptr) {
  if(thisptr->arglist.size() == 0) {
    return 1;
  } else {
    return thisptr->arglist[0] + 1;
  }
}

int indicators::rsi_lookback(indicators* thisptr) {
  if(thisptr->arglist.size() == 0) {
    return TA_RSI_Lookback(14) * 4;
  } else {
    return TA_RSI_Lookback((int) thisptr->arglist[0]) * 4;
  }
}

int indicators::ema_lookback(indicators* thisptr) {
  return TA_EMA_Lookback((int) thisptr->arglist[0]) * 4;
}

int indicators::avg_true_range_lookback(indicators* thisptr) {
  if(thisptr->arglist.size() == 0) {
    return TA_ATR_Lookback(14) + 1;
  } else {
    return TA_ATR_Lookback((int) thisptr->arglist[0]) + 1;
  }
}

int indicators::accl_lookback(indicators* thisptr) {
  if(thisptr->arglist.size() == 0) {
    return 21;
  } else {
    return thisptr->arglist[0] + 1;
  }
}

int indicators::natr_lookback(indicators* thisptr) {
  if(thisptr->arglist.size() == 0) {
    return TA_ATR_Lookback(14) + 1;
  } else {
    return TA_ATR_Lookback((int) thisptr->arglist[0]) + 1;
  }
}

int indicators::obv_lookback(indicators* thisptr) {
  return 1;
}

int indicators::roc_lookback(indicators* thisptr) {
  if(thisptr->arglist.size() == 0) {
    return 13;
  } else {
    return ((int) thisptr->arglist[0]) + 1;
  }
}

int indicators::bollinger_lookback(indicators* thisptr) {
  if(thisptr->arglist.size() == 0) {
    return TA_BBANDS_Lookback(20, 2.0, 2.0, TA_MAType_SMA) + 1;
  } else {
    return TA_BBANDS_Lookback((int)thisptr->arglist[0], thisptr->arglist[1], thisptr->arglist[1], TA_MAType_SMA) + 1;
  }
}

int indicators::aroon_osc_lookback(indicators* thisptr) {
  if(thisptr->arglist.size() == 0) {
    return TA_AROONOSC_Lookback(25) + 1;
  } else {
    return TA_AROONOSC_Lookback(thisptr->arglist[0]) + 1;
  }
}
