#include <string>
#ifndef TP_DATE
#define TP_DATE
using namespace std;

class date {

  public:
    date(string);
    date(const date&);
    date(unsigned int);
    string to_s();
    int int_image();
    void next_day();
    void prev_day();
    void next_business_day();
    void prev_business_day();
    bool is_weekday();

    int diff_days(date);
    int diff_bdays(date);

    int getyear();
    int getmonth();
    int getday();

    bool operator==(const date) const;
    bool operator<(const date) const;
    bool operator>(const date) const;
  private:
  
    int day_of_week();
    bool is_leap_year();
    time_t time_to_epoch(const struct tm*);

    static const short LEAP_DAY = 28;
    static const short MAX_MONTH = 12;
    static const short LEAP_MONTH  = 2;
    static const short MONTH_LENGTHS[];
    static const short MONTH_CODES[];
    static const int SECONDS_PER_DAY = 86400;
    short month, day;
    int year;
};

#endif
