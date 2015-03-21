#include <sstream>
#include <iomanip>
#include "date.h"

const short date::MONTH_LENGTHS[] = {-1, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
const short date::MONTH_CODES[] = {0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4};

date::date(string s) {
  int y, m, d;
  sscanf(s.c_str(), "%4d-%2d-%2d", &y, &m, &d);
  day = d;
  year = y;
  month = m;
}

date::date(const date& src) {
  day = src.day;
  year = src.year;
  month = src.month;
}

date::date(unsigned int dcode) {
  day = dcode % 100;
  dcode /= 100;
  month = dcode % 100;
  year = dcode / 100;
}

string date::to_s() {
  ostringstream rval;
  rval << year << '-';
  rval << setw(2) << setfill('0') <<  month << '-';
  rval << setw(2) << setfill('0') << day;
  return rval.str();
}

void date::next_day() {
  day++;

  if(day > MONTH_LENGTHS[month]) {
    if(!(month == LEAP_MONTH && day == (LEAP_DAY+1) && is_leap_year())) {
      day = 1;
      month++;
    }
  }

  if(month > MAX_MONTH) {
    year++;
    day = 1;
    month = 1;
  }
}

void date::prev_day() {
  day--;

  if(day == 0) {

    month--;

    if(month == LEAP_MONTH && is_leap_year()) {
      day = LEAP_DAY + 1;
    } else {
      day = MONTH_LENGTHS[month];
    }

    if(month == 0) {
      day = MONTH_LENGTHS[MAX_MONTH];
      month = MAX_MONTH;
      year--;
    }
  }
}

void date::next_business_day() {
  do {
    next_day();
  } while(! is_weekday());
}

void date::prev_business_day() {
  do {
    prev_day();
  } while(! is_weekday());
}

//TÃ¸ndering's algorithm via Tomohiko Sakamoto
//0 is a sunday, 6 is a saturday.  Works for year > 1752
//see: http://en.wikipedia.org/wiki/Determination_of_the_day_of_the_week

bool date::is_weekday() {
  int y = year; //year isn't always preserved
  y -= month < 3;
  int code = (y + y/4 - y/100 + y/400 + MONTH_CODES[month-1] + day) % 7;
  return (code != 0 && code != 6);
}

//Leap Years are any year that can be evenly divided by 4
//except if it can can be evenly divided by 100, then it isn't
//except if it can be evenly divided by 400, then it is

bool date::is_leap_year() {
  if(year % 4 == 0) {
    if((year % 100 == 0) && (year % 400 != 0)) {
        return false;
    }

    return true;
  }

  return false;
}

bool date::operator==(date d) const {
  return (year == d.year) && (month == d.month) && (day == d.day);
}

bool date::operator<(date d) const {
  if(year > d.year)
    return false;

  if(year == d.year) {
    if(month > d.month) {
      return false;
    } else if(month == d.month) {
      if(day >= d.day) {
        return false;
      }
    }
  }

  return true;
}

bool date::operator>(date d) const {
  if(year < d.year)
    return false;

  if(year == d.year) {
    if(month < d.month) {
      return false;
    } else if(month == d.month) {
      if(day <= d.day) {
        return false;
      }
    }
  }

  return true;
}

int date::int_image() {
  return (year * 10000) + (month * 100) + day;
}

int date::getyear() {
  return year;
}

int date::getmonth() {
  return month;
}

int date::getday() {
  return day;
}
