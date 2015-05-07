#ifndef STRATEGY
#define STRATEGY
#include "screen.h"

class strategy {

  public:

    strategy();
    void set_universe(vector<std::string>);
    void set_date_range(date, date);
    void long_entry_trigger(screen);
    void long_entry_signal(screen);
    void long_exit_trigger(screen);
    void long_exit_signal(screen);
    void evaluate();

  private:


};


#endif
