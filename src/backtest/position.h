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
    void update(date);
    void close(date);
    float cost();

  private:
    void split_adjust(date);

    string ticker;
    date* open_date;
    date* close_date;
    float split_fraction;
    float close_cost;
    float open_cost;
    int count;
    bool open;

    static std::map<string, ptable*> open_equities;
};

#endif
