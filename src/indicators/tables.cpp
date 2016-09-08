#include "indicators.h"

std::map<std::string, float (*)(indicators*)> indicators::fn_table;
std::map<std::string, int (*)(indicators*)> indicators::lookback_table;

void indicators::init_fntable() {
  indicators::fn_table["V"] = &indicators::volume_at;
  indicators::fn_table["C"] = &indicators::close_at;
  indicators::fn_table["O"] = &indicators::open_at;
  indicators::fn_table["H"] = &indicators::high_at;
  indicators::fn_table["L"] = &indicators::low_at;
  indicators::fn_table["DATE"] = &indicators::date_at;

  indicators::fn_table["MAXO"] = &indicators::max_open;
  indicators::fn_table["MAXH"] = &indicators::max_high;
  indicators::fn_table["MAXL"] = &indicators::max_low;
  indicators::fn_table["MAXC"] = &indicators::max_close;
  indicators::fn_table["MAXV"] = &indicators::max_volume;

  indicators::fn_table["MINO"] = &indicators::min_open;
  indicators::fn_table["MINH"] = &indicators::min_high;
  indicators::fn_table["MINL"] = &indicators::min_low;
  indicators::fn_table["MINC"] = &indicators::min_close;
  indicators::fn_table["MINV"] = &indicators::min_volume;

  indicators::fn_table["AVGO"] = &indicators::avgo;
  indicators::fn_table["AVGH"] = &indicators::avgh;
  indicators::fn_table["AVGL"] = &indicators::avgl;
  indicators::fn_table["AVGC"] = &indicators::avgc;
  indicators::fn_table["AVGV"] = &indicators::avgv;

  indicators::fn_table["EMAO"] = &indicators::eavgo;
  indicators::fn_table["EMAH"] = &indicators::eavgh;
  indicators::fn_table["EMAL"] = &indicators::eavgl;
  indicators::fn_table["EMAC"] = &indicators::eavgc;
  indicators::fn_table["EMAV"] = &indicators::eavgv;

  indicators::fn_table["WMAC"] = &indicators::wmac;
  indicators::fn_table["WMAH"] = &indicators::wmah;
  indicators::fn_table["WMAL"] = &indicators::wmal;
  indicators::fn_table["WMAO"] = &indicators::wmao;
  indicators::fn_table["WMAV"] = &indicators::wmav;

  indicators::fn_table["ATR"] = &indicators::avg_true_range;
  indicators::fn_table["ROC"] = &indicators::roc;
  indicators::fn_table["NATR"] = &indicators::natr;
  indicators::fn_table["RSI"] = &indicators::rsi;
  indicators::fn_table["OBV"] = &indicators::obv;
  indicators::fn_table["AROON_OSC"] = &indicators::aroon_osc;

  indicators::fn_table["ACCELERATION_UPPER"] = &indicators::accl_upper;
  indicators::fn_table["ACCELERATION_LOWER"] = &indicators::accl_lower;

  indicators::fn_table["BOLLINGER_UPPER"] = &indicators::bollinger_upper;
  indicators::fn_table["BOLLINGER_LOWER"] = &indicators::bollinger_lower;

  indicators::fn_table["AGE"] = &indicators::data_age;
  indicators::fn_table["ABS"] = &indicators::abs_value;
  indicators::fn_table["MAX"] = &indicators::largest;
  indicators::fn_table["MIN"] = &indicators::smallest;
  indicators::fn_table["ROUND"] = &indicators::round;
  indicators::fn_table["FLOOR"] = &indicators::floor;
  indicators::fn_table["CEIL"] = &indicators::ceil;

  indicators::fn_table["PORTFOLIO_POSITION_COUNT"] = &indicators::portfolio_count;
  indicators::fn_table["PORTFOLIO_EQUITY"] = &indicators::portfolio_equity;
  indicators::fn_table["PORTFOLIO_RETURN"] = &indicators::portfolio_return;
  indicators::fn_table["PORTFOLIO_CASH"] = &indicators::portfolio_cash;

  indicators::fn_table["POSITION_RETURN_PERCENT"] = &indicators::position_return_percent;
  indicators::fn_table["POSITION_SHARE_COUNT"] = &indicators::position_share_count;
  indicators::fn_table["POSITION_BUY_PRICE"] = &indicators::position_buy_price;
  indicators::fn_table["POSITION_DAYS_HELD"] = &indicators::position_days_held;
  indicators::fn_table["POSITION_RETURN_R"] = &indicators::position_return_r;
}

void indicators::init_lookback_table() {
  indicators::lookback_table["O"] = &indicators::ohlcv_lookback;
  indicators::lookback_table["H"] = &indicators::ohlcv_lookback;
  indicators::lookback_table["L"] = &indicators::ohlcv_lookback;
  indicators::lookback_table["C"] = &indicators::ohlcv_lookback;
  indicators::lookback_table["V"] = &indicators::ohlcv_lookback;
  indicators::lookback_table["DATE"] = &indicators::ohlcv_lookback;

  indicators::lookback_table["MAXO"] = &indicators::minimax_lookback;
  indicators::lookback_table["MAXH"] = &indicators::minimax_lookback;
  indicators::lookback_table["MAXL"] = &indicators::minimax_lookback;
  indicators::lookback_table["MAXC"] = &indicators::minimax_lookback;
  indicators::lookback_table["MAXV"] = &indicators::minimax_lookback;

  indicators::lookback_table["MINO"] = &indicators::minimax_lookback;
  indicators::lookback_table["MINH"] = &indicators::minimax_lookback;
  indicators::lookback_table["MINL"] = &indicators::minimax_lookback;
  indicators::lookback_table["MINC"] = &indicators::minimax_lookback;
  indicators::lookback_table["MINV"] = &indicators::minimax_lookback;

  indicators::lookback_table["AVGO"] = &indicators::identity_lookback;
  indicators::lookback_table["AVGH"] = &indicators::identity_lookback;
  indicators::lookback_table["AVGL"] = &indicators::identity_lookback;
  indicators::lookback_table["AVGC"] = &indicators::identity_lookback;
  indicators::lookback_table["AVGV"] = &indicators::identity_lookback;

  indicators::lookback_table["EMAO"] = &indicators::ema_lookback;
  indicators::lookback_table["EMAH"] = &indicators::ema_lookback;
  indicators::lookback_table["EMAL"] = &indicators::ema_lookback;
  indicators::lookback_table["EMAC"] = &indicators::ema_lookback;
  indicators::lookback_table["EMAV"] = &indicators::ema_lookback;
  
  indicators::lookback_table["WMAC"] = &indicators::identity_lookback;
  indicators::lookback_table["WMAO"] = &indicators::identity_lookback;
  indicators::lookback_table["WMAH"] = &indicators::identity_lookback;
  indicators::lookback_table["WMAL"] = &indicators::identity_lookback;
  indicators::lookback_table["WMAV"] = &indicators::identity_lookback;

  indicators::lookback_table["ATR"] = &indicators::avg_true_range_lookback;
  indicators::lookback_table["ROC"] = &indicators::roc_lookback;
  indicators::lookback_table["RSI"] = &indicators::rsi_lookback;
  indicators::lookback_table["OBV"] = &indicators::obv_lookback;
  indicators::lookback_table["NATR"] = &indicators::natr_lookback;
  indicators::lookback_table["AROON_OSC"] = &indicators::aroon_osc_lookback;

  indicators::lookback_table["ACCELERATION_UPPER"] = &indicators::accl_lookback;
  indicators::lookback_table["ACCELERATION_LOWER"] = &indicators::accl_lookback;

  indicators::lookback_table["BOLLINGER_UPPER"] = &indicators::bollinger_lookback;
  indicators::lookback_table["BOLLINGER_LOWER"] = &indicators::bollinger_lookback;

  indicators::lookback_table["AGE"] = &indicators::age_lookback;
  indicators::lookback_table["ABS"] = &indicators::null_lookback;
  indicators::lookback_table["MAX"] = &indicators::null_lookback;
  indicators::lookback_table["MIN"] = &indicators::null_lookback;
  indicators::lookback_table["ROUND"] = &indicators::null_lookback;
  indicators::lookback_table["FLOOR"] = &indicators::null_lookback;
  indicators::lookback_table["CEIL"] = &indicators::null_lookback;

  indicators::lookback_table["PORTFOLIO_POSITION_COUNT"] = &indicators::null_lookback;
  indicators::lookback_table["PORTFOLIO_EQUITY"] = &indicators::null_lookback;
  indicators::lookback_table["PORTFOLIO_RETURN"] = &indicators::null_lookback;
  indicators::lookback_table["PORTFOLIO_CASH"] = &indicators::null_lookback;

  indicators::lookback_table["POSITION_RETURN_PERCENT"] = &indicators::null_lookback;
  indicators::lookback_table["POSITION_SHARE_COUNT"] = &indicators::null_lookback;
  indicators::lookback_table["POSITION_BUY_PRICE"] = &indicators::null_lookback;
  indicators::lookback_table["POSITION_DAYS_HELD"] = &indicators::null_lookback;
  indicators::lookback_table["POSITION_RETURN_R"] = &indicators::null_lookback;
}
