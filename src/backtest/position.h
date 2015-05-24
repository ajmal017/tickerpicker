#ifndef POSITION
#define POSITION
#include "ptable.h"
#include "date.h"

class position {

  public:
    position(date, string, int, float);
    position(date, string, int);
    float position_value(date);
    bool matches(string);
    void print_state();
    int share_count();
    void close(date);
    float cost();

  private:
    string ticker;
    date* open_date;
    date* close_date;
    float close_cost;
    float open_cost;
    int count;
    bool open;

    static std::map<string, ptable*> open_equities;
};

#endif
