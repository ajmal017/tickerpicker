#ifndef POSITION
#define POSITION
#include "ruleset.h"
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
    string symbol();
    float cost();

    void close(date, float);
    void close(date);

  private:
    void split_adjust(date);
    float percent_diff();

    date* open_date;
    date* close_date;
    expression* initial_stop;
    expression* trailing_stop;

    vector<float> stop_history;
    float split_fraction;
    float close_cost;
    float open_cost;
    string ticker;
    int count;
    bool open;

    static std::map<string, ptable*> open_equities;
};

#endif
