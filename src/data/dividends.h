#ifndef DIVDATA
#define DIVDATA
#include "date.h"
#include <fstream>
#include <string>
#include <map>

class dividends {
  public:
    dividends(string);
    float on_date(date);
    static bool exists(std::string);
    int count();
  private:
    static std::string pathto(std::string);
    void seek_to_date(date);
    void load();

    ifstream divfile;
    std::map<date, float> divtable;
};

#endif
