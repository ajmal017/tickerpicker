#include "indicators.h"

float indicators::portfolio_equity(indicators*) {
  return fn_portfolio->equity();
}

float indicators::portfolio_return(indicators*) {
  return fn_portfolio->total_return();
}

float indicators::portfolio_count(indicators*) {
  return fn_portfolio->position_count();
}

float indicators::portfolio_cash(indicators*) {
  return fn_portfolio->cash();
}

float indicators::position_return_percent(indicators*) {
  if(fn_position) {
    return fn_position->percent_return();
  }
}

float indicators::position_share_count(indicators*) {
  if(fn_position) {
    return fn_position->share_count();
  }
}

float indicators::position_buy_price(indicators*) {
  if(fn_position) {
    return fn_position->purchase_price();
  }
}

float indicators::position_return_r(indicators*) {
  if(fn_position) {
    return fn_position->risk_return();
  }
}

float indicators::position_days_held(indicators*) {
  if(fn_position) {
    return fn_position->days_held();
  }
}
