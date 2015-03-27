#ifndef PDATA
#define PDATA
#include <vector>
#include "date.h"

class pdata {
  public:

  vector<float> low;
  vector<float> open;
  vector<float> high;
  vector<float> close;
  vector<uint32_t> date;
  vector<uint32_t> volume;

  int size();
  void clear();
  bool has_gaps(); 
  bool is_valid(::date, int);
  void concat_history(pdata);

  private:
  static const int MAX_GAP = 5;
  static const int MAX_OLD = 10;
};

#endif
