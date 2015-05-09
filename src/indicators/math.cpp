#include "indicators.h"
#include <algorithm>
#include <cmath>

float indicators::abs_value(indicators* thisptr) {
  return abs(thisptr->arglist[0]);
}

float indicators::largest(indicators* thisptr) {
  return *std::max_element(thisptr->arglist.begin(), thisptr->arglist.end());
}

float indicators::smallest(indicators* thisptr) {
  return *std::min_element(thisptr->arglist.begin(), thisptr->arglist.end());
}

float indicators::round(indicators* thisptr) {
  return ::round(thisptr->arglist[0]);
}

float indicators::floor(indicators* thisptr) {
  return ::floor(thisptr->arglist[0]);
}

float indicators::ceil(indicators* thisptr) {
  return ::ceil(thisptr->arglist[0]);
}
