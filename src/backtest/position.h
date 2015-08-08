#ifndef POSITION
#define POSITION
#include "strategy.h"
#include "ruleset.h"
#include "ptable.h"
#include "date.h"

class position : public restrictor {

  public:
    position(date, string, int, strategy*, float);
    position(date, string, int, strategy*);
    float position_value(date);
    bool matches(string);
    void print_state();
    int share_count();
    void update(date);
    string symbol();
    float cost();

    bool skip_ticker(string);
    bool exit(date);
    bool stopped_out(date);
    void close(date);

    bool operator ==(const position& p) {
      return p.ticker == ticker; 
    }

  private:     
    void split_adjust(date);
    float percent_diff();

    date* open_date;
    date* close_date;
    expression* initial_stop;
    expression* trailing_stop;
    strategy* this_strat;

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
