#ifndef CONFIG
#define CONFIG
#include "../rapidjson/document.h"
#include "ruleset.h"
#include <string>

class config {
  friend class portfolio;

  public:
    config(rapidjson::Value&);
    static bool shuffle();

  private:
    bool bvalue(rapidjson::Value&, std::string);

    static float initial_equity();
    static bool single_pos();
    static string benchmark();
    static bool multiple_positions;
    static expression* slippage;
    static string benchticker;
    static float start_equity;
    static bool shuffle_universe;
};

#endif
