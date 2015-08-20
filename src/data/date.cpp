#include <sstream>
#include <iostream>
#include <iomanip>
#include <time.h>
#include "date.h"

const short date::MONTH_LENGTHS[] = {-1, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
const short date::MONTH_CODES[] = {-1, 0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4};

date::date() {

}

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
  } while(is_static_holiday() || ! is_weekday());
}

void date::prev_business_day() {
  do {
    prev_day();
  } while(is_static_holiday() || ! is_weekday());
}

//TÃ¸ndering's algorithm via Tomohiko Sakamoto
//0 is a sunday, 6 is a saturday.  Works for year > 1752
//see: http://en.wikipedia.org/wiki/Determination_of_the_day_of_the_week
//return (y + y/4 - y/100 + y/400 + MONTH_CODES[month] + day) % 7;

int date::day_of_week() {
  int y = year; //year isn't always preserved
  y -= month < 3;
  return ((501*y / 400) - (4 * y / 400) + MONTH_CODES[month] + day) % 7;
}

bool date::is_weekday() {
  int code = day_of_week();
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

bool date::is_static_holiday() {
  return (month == 7 && day == 4) || (month == 12 && day == 25) ||
	(month == 1 && day == 1);
}

int date::diff_days(date other) {
  struct tm thisday;
  struct tm otherday;

  thisday.tm_sec = 0;
  thisday.tm_min = 0;
  thisday.tm_hour = 0;
  thisday.tm_mday = day;
  thisday.tm_year = year;
  thisday.tm_mon = month - 1;

  otherday.tm_sec = 0;
  otherday.tm_min = 0;
  otherday.tm_hour = 0;
  otherday.tm_mday = other.day;
  otherday.tm_year = other.year;
  otherday.tm_mon = other.month - 1;

  time_t thistime = time_to_epoch(&thisday);
  time_t othertime = time_to_epoch(&otherday);

  uint32_t diff = thistime - othertime;
  return diff / SECONDS_PER_DAY;
}


//replacement for pathetically slow native mktime
//causing literal order of magnitude slowdown
//translated from https://gmbabar.wordpress.com/2010/12/01/mktime-slow-use-custom-function/

time_t date::time_to_epoch (const struct tm *ltm) {
   const int mon_days [] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
   long tyears, tdays, leaps, utc_hrs;
   int i;

   tyears = ltm->tm_year - 70 ; // tm->tm_year is from 1900.
   leaps = (tyears + 2) / 4; // no of next two lines until year 2100.

   tdays = 0;
   for (i=0; i < ltm->tm_mon; i++) tdays += mon_days[i];

   tdays += ltm->tm_mday-1; // days of month passed.
   tdays = tdays + (tyears * 365) + leaps;

   utc_hrs = ltm->tm_hour - 5; //Eastern Standard Time
   return (tdays * 86400) + (utc_hrs * 3600) + (ltm->tm_min * 60) + ltm->tm_sec;
}

//Translated from internet sources:
//http://alecpojidaev.wordpress.com/2009/10/29/work-days-calculation-with-c/
//http://stackoverflow.com/questions/1617049/calculate-the-number-of-business-days-between-two-dates
//and then modified to avoid repeated calls to day_of_week, a runtime hotspot

int date::diff_bdays(date other) {
  int thisday = day_of_week();
  int otherday = other.day_of_week();
  int diff = 1 + (diff_days(other) * 5 - (otherday - thisday) * 2) / 7;
  if (thisday == 6) diff--;
  if (otherday == 0) diff--;
  return diff;
}

bool date::operator==(date d) const {
  return (year == d.year) && (month == d.month) && (day == d.day);
}

bool date::operator!=(date d) const {
  return (year != d.year) || (month != d.month) || (day != d.day);
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

bool date::operator<=(const date d) const {
  return this->date::operator<(d) || this->date::operator==(d);
}

bool date::operator>=(const date d) const {
  return this->date::operator>(d) || this->date::operator==(d);
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
