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
