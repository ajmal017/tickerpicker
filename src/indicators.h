#ifndef INDICATORS
#define INDICATORS

class indicators {

  int eval_lookback(string);
  void eval_indicator(string);

  private:

  //lookback period calculators
  int close_lookback();
  
  //actual indicator functions
  float indicator_close();


};

#endif
