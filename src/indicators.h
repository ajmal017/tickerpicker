#ifndef INDICATORS
#define INDICATORS
#include "ptable.h"
#include <vector>
#include <string>
#include <map>

//output buffer large enough to look back
//five years on functions that require 
//large pulls due to unstable periods

#define OUTPUT_BUFSIZE 5200

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
  int rsi_lookback();
  int ema_lookback();
  int ohlcv_lookback();
  int absval_lookback();
  int identity_lookback();
  int avg_true_range_lookback();
  
  //actual indicator functions
  float rsi();
  float obv();
  float avgc();
  float avgo();
  float avgh();
  float avgl();
  float avgv();
  float eavgc();
  float eavgo();
  float eavgh();
  float eavgl();
  float eavgv();
  float wmac();
  float wmao();
  float wmah();
  float wmal();
  float wmav();
  float volume_at();
  float close_at();
  float open_at();
  float high_at();
  float low_at();
  float max_open();
  float max_high();
  float max_low();
  float max_close();
  float max_volume();
  float min_open();
  float min_high();
  float min_low();
  float min_close();
  float min_volume();
  float abs_value();
  float avg_true_range();
  float sma(vector<float>);
  float wma(vector<float>);
  float eavg(vector<float>);
  float internal_minval(vector<float>, int);
  float internal_maxval(vector<float>, int);
};

#endif
