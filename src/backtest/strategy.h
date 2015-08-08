#ifndef STRATEGY
#define STRATEGY
#include "screen.h"

class strategy {

  public:

    strategy();
    void set_universe(std::vector<std::string>);
    void trailing_stop(std::vector<std::string>);
    void stop_loss(std::vector<std::string>);
    void entry_trigger(screen*);
    void entry_signal(screen*);
    void exit_trigger(screen*);
    void exit_signal(screen*);
    void set_date(date);

    std::vector<std::string> entry_signal(date, restrictor*);
    std::vector<std::string> exit_signal(date, restrictor*);
    float stop_loss(date, std::string);

  private:

    expression* trail_stop;
    expression* init_stop;
    screen* enter_signal;
    screen* enter_trigger;
    screen* xit_signal;
    screen* xit_trigger;

};

#endif
