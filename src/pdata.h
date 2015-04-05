#ifndef PDATA
#define PDATA
#include <vector>
#include <map>
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
  void dump_data();
  bool is_valid(::date, int);
  void concat_history(pdata);
  void add_split(::date, pair<uint16_t, uint16_t>); 
  vector<float> volume_as_floats();

  private:
  void concat_prices(pdata);
  void concat_splits(pdata);
  void apply_split(::date, uint16_t, uint16_t);

  map<uint32_t, pair<uint16_t, uint16_t> > splitlist;  
  static const int MAX_GAP = 5;
  static const int MAX_OLD = 10;
};

#endif
