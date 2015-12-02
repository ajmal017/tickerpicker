#ifndef CMDLINE
#define CMDLINE
#include "rapidjson/document.h"
#include "screen.h"
#include <fstream>
#include <vector>

void tokenize(const std::string& str, std::vector<std::string>& tokens) {
  std::string::size_type lastPos = str.find_first_not_of(",", 0);
  std::string::size_type pos = str.find_first_of(",", lastPos);

  while (std::string::npos != pos || std::string::npos != lastPos) {
    tokens.push_back(str.substr(lastPos, pos - lastPos));
    lastPos = str.find_first_not_of(",", pos);
    pos = str.find_first_of(",", lastPos);
  }
}

std::vector<std::string> get_universe(char *argv[], int startidx) {
  std::vector<std::string> u;
  std::string ticker;
  
  if(std::string(argv[startidx]).compare("-f") == 0) {

    std::ifstream listfile(argv[startidx + 1]);

    if(!listfile) {
      cout << "File " << argv[startidx + 1] << " not found\n";
      exit(1);
    }

    while(getline(listfile, ticker)) {
      u.push_back(ticker);
    }

  } else {
    std::string tlist(argv[startidx + 1]);
    tokenize(tlist, u);
  }

  return u;
}

screen* process_screen(rapidjson::Value& v) {
  rapidjson::Value& rules = v["rules"];
  rapidjson::Value& symbols = v["symbols"];
  std::vector<std::string> rulevec, symvec, sortvec;
  rapidjson::Value sort;
  bool sflag;

  for(rapidjson::SizeType i = 0; i < rules.Size(); i++) {
    std::string t = rules[i].GetString();
    rulevec.push_back(t);
  }

  for(rapidjson::SizeType i = 0; i < symbols.Size(); i++) {
    std::string t = symbols[i].GetString();
    symvec.push_back(t);
  }

  screen *rval = new screen(rulevec, symvec);

  if(v.HasMember("asort")) {
    sort = v["asort"];
    sflag = true;
  }

  if(v.HasMember("dsort")) {
    sort = v["dsort"];
    sflag = false;
  }

  if(!sort.IsNull()) {

    for(rapidjson::SizeType i = 0; i < sort.Size(); i++) {
      std::string t = sort[i].GetString();
      sortvec.push_back(t);
    }

    rval->set_sort_exp(sortvec, sflag);
  }

  return rval;
}

#endif
