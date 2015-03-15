#include <string>
#ifndef TP_DATE
#define TP_DATE
using namespace std;

class date {

  public:
    date(string);
    string to_s();
    void next_day();
    void prev_day();
    void next_business_day();
    void prev_business_day();
    bool is_weekday();

    bool operator==(date);
    bool operator<(date);
    bool operator>(date);
  private:
  
    bool is_leap_year();

    static const short LEAP_DAY = 28;
    static const short MAX_MONTH = 12;
    static const short LEAP_MONTH  = 2;
    static const short MONTH_LENGTHS[];
    static const short MONTH_CODES[];
    short month, day;
    int year;
};

#endif
