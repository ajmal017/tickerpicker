#ifndef INDICATORS
#define INDICATORS
#include "ptable.h"
#include <vector>
#include <string>
#include <map>

typedef void (*indicatorfn)(void);;


class indicators {

  public:

  indicators();
  int eval_lookback(std::string, std::vector<float>);
  float eval_indicator(std::string, std::vector<float>, pdata*);

  private:

  pdata *current_prices;
  std::vector<float> arglist;
  std::map<std::string, float (indicators::*)()> fn_table;
  std::map<std::string, int (indicators::*)()> lookback_table;

  void init_fntable(); 
  void init_lookback_table();

  //lookback period calculators
  int ohlcv_lookback();
  
  //actual indicator functions
  float volume_at();
  float close_at();
  float open_at();
  float high_at();
  float low_at();


};

#endif
