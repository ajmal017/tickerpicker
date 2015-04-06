#include "indicators.h"

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

