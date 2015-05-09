#ifndef PORTFOLIO
#define PORTFOLIO
#include "strategy.h"
#include "position.h"

class portfolio {

  public:
    void run();
    void set_date_range(date, date);
    void set_universe(vector<std::string>);
    void set_long_strategies(std::vector<strategy>);

  private:

    void close_positions(std::vector<std::string>, date);
    void open_positions(std::vector<std::string>, date);
    std::vector<std::string> entry_signals(date);
    std::vector<std::string> exit_signals(date);

    std::vector<strategy> long_strategies;
    std::vector<string> stock_universe;

    std::vector<position> cur_positions;
    std::vector<position> old_positions;

    date* firstdate;
    date* lastdate;
};

#endif
