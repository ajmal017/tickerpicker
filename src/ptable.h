#ifndef PTABLE 
#define PTABLE 
#include <fstream>
#include <vector>
#include "date.h"
#include <map>

struct pdata {
  vector<float> low;
  vector<float> open;
  vector<float> high;
  vector<float> close;
  vector<uint32_t> date;
  vector<uint32_t> volume;
};

class ptable {
  public:

  enum dayindices { DATE, OPEN, HIGH, LOW, CLOSE, VOLUME };

  ptable(string);
  pdata read(int);
  pdata pull_history_by_limit(date, int);
  float pull_close_on_date(date);
  void pull_history_by_dates();
  static void dump_data(pdata);
  void pull_dividends();

  private:

  void open();
  void find_row(int);
  int find_row(date);
  void read_splits();
  void read_rowcount();
  void read_index_header();
  int binary_search(int, int, int);
  pdata store_rows(uint32_t*, int);

  string symbol;
  ifstream binfile;
  std::map<date, pair<uint16_t, uint16_t> > splits;
  std::map<uint16_t, uint32_t> index;
  unsigned int rstart;
  unsigned int rcount;

  static const int UINT_BYTES = 4;
  static const int ROW_SIZE = 24; 
  static const int ROW_COUNT = 6;
  static const float SCALE = 100.0;
};

#endif
