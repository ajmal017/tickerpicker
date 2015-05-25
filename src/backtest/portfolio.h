#ifndef PORTFOLIO
#define PORTFOLIO
#include "strategy.h"
#include "position.h"

class portfolio {

  public:
    void run();
    void print_state();
    void set_date_range(date, date);
    void set_universe(vector<std::string>);
    void set_long_strategies(std::vector<strategy>);

  private:

    void close_positions(std::vector<std::string>, date);
    void open_positions(std::vector<std::string>, date);
    std::vector<std::string> entry_signals(date);
    std::vector<std::string> exit_signals(date);
    void update_equity_curve(date);
    void update_positions(date);

    std::vector<strategy> long_strategies;
    std::vector<string> stock_universe;

    std::vector<position> cur_positions;
    std::vector<position> old_positions;
    std::vector<float> equity_curve;

    date* firstdate;
    date* lastdate;
    float cur_cash;
};

#endif
