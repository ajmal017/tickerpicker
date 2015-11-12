#include "dividends.h"
#include <arpa/inet.h>
#include <sys/stat.h>


#include <iostream>

dividends::dividends(string symbol) {
  string fname = pathto(symbol);
  divfile.open(fname.c_str(), ios::in | ios::binary);
}

float dividends::on_date(date d) {
  if(divtable.size() == 0) {
    load();
  }

  if(divtable.count(d) > 0) {
    return divtable[d];
  }

  return 0;
}

bool dividends::exists(std::string target) {
  struct stat sb;
  string fname = pathto(target);
  return stat(fname.c_str(), &sb) != -1;  
}

int dividends::count() {
  divfile.seekg(0, divfile.end);
  return divfile.tellg() / 8;
}

void dividends::load() {
  int thedate;
  unsigned long div;
  divfile.seekg(0, divfile.beg);

  while(!divfile.eof()) {
    divfile.read((char *) &thedate, 4);
    divfile.read((char *) &div, 4);

    thedate = ntohl(thedate);
    div = ntohl(div);

    float f = (float)div / 10000.0;
    date d(thedate);
    divtable[d] = f;
  }
}

string dividends::pathto(string target) {
  return "ptabs/" + target + ".div";
}
