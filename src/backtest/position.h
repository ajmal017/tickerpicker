#ifndef POSITION
#define POSITION
#include "strategy.h"
#include "ruleset.h"
#include "ptable.h"
#include "date.h"

class position : public restrictor, position_metric {

  public:
    static const std::string DEFER_OK;

    position(date, string, int, strategy*, float);
    position(date, string, int, strategy*);
    float position_value(date);
    bool matches(string);
    void print_state();
    float update(date);
    string symbol();
    float cost();

    int share_count();
    float purchase_price();
    float percent_return();  
    float risk_return();
    float div_payout();
    float days_held();

    void print_stop_curve();
    bool skip_ticker(string);
    bool exit(date);
    bool stopped_out(date);
    void close(date);

    bool operator ==(const position& p) {
      return p.ticker == ticker; 
    }

  private:     
    float split_adjust(date);
    void update_stop(date);
    float percent_diff();
    float dividend(date);

    date* cur_date;
    date* open_date;
    date* close_date;
    dividends* divdata;
    strategy* this_strat;

    vector<float> stop_history;
    float total_payout;
    float close_cost;
    float open_cost;
    string ticker;
    int count;
    bool open;

    static std::map<string, ptable*> open_equities;
};

#endif
