#ifndef PORTFOLIO
#define PORTFOLIO
#include "strategy.h"
#include "position.h"
#include "config.h"
#include <set>

class target_list : public restrictor {
  public:
    target_list(string);
    target_list(vector<string>);
    bool skip_ticker(string);
  private:
    set<string> targets;
};

class portfolio : public restrictor {

  public:
    void run();
    void print_state();
    void set_date_range(date, date);
    void set_universe(vector<std::string>);
    void set_long_strategies(std::vector<strategy>);
    bool skip_ticker(string);

  private:

    void close_positions(std::vector<std::string>*, date);
    void close_position(date, int, std::vector<std::string>*, float p=0);
    void open_positions(std::vector<std::string>*, std::vector<strategy>*, date);
    void entry_signals(date, std::vector<std::string>*, std::vector<strategy>*);
    void process_stops(date, std::vector<std::string>*);
    void exit_signals(date, std::vector<std::string>*);
    target_list get_current_restrictor();
    void update_equity_curve(date);
    void update_positions(date);

    std::vector<strategy> long_strategies;
    std::vector<strategy> cur_strategies;
    std::vector<string> stock_universe;

    std::vector<position> cur_positions;
    std::vector<position> old_positions;
    std::vector<float> equity_curve;

    date* firstdate;
    date* lastdate;
    float cur_cash;
};

#endif
