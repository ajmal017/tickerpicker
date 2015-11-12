#include "portfolio.h"
#include <cmath>
#define YEAR_SIZE 260

void archive::push(position* p) {
  old_positions.push_back(p);
}

void archive::push_benchmark(float p) {
  benchmark_curve.push_back(p);
}

void archive::update_equity(float equity) {
  equity_curve.push_back(equity);
}

float archive::total_return() {
  float start = equity_curve.front();
  float end = equity_curve.back();
  float diff = ((end - start) / start) * 100;
  return floor(diff * 100) / 100;
}

float archive::current_equity() {
  return equity_curve.back();
}

void archive::compute_basic_stats() {

  float totalwin = 0;
  float totalloss = 0;
  winners = losers = 0;

  for(int i = 0; i < old_positions.size(); i++) {
    float retamt = old_positions[i]->percent_return();
    if(retamt > 0) {
      winners++;
      totalwin += retamt;
    } else {
      losers++;
      totalloss += retamt;
    }
  }

  if(winners > 0 && losers > 0) {
    avgwin = totalwin / winners;
    avgloss = totalloss / losers;    

    float win_ratio = winners / old_positions.size();
    expectancy = (win_ratio * avgwin) + ((1 - win_ratio) * avgloss);
    winpercent = (float) winners / (winners + losers);
    losepercent = (float) losers / (winners + losers);
  }
}

float archive::max_drawdown() {

  float max = equity_curve[0];
  float min = equity_curve[0];
  float max_drawdown = 0;  

  for(int i = 0; i < equity_curve.size(); i++) {
    float equity = equity_curve[i];
    
    if(equity >= max) {
      max = equity;
      min = max;    
    } else if(equity <= min) {
      min = equity;
      float d = ((max - min) / max) * 100;
      max_drawdown = (d > max_drawdown ? d : max_drawdown); 
    } 
  }
 
  return max_drawdown;
}

float archive::cagr() {
  int yearcount = equity_curve.size() / YEAR_SIZE;
  double base = (equity_curve.back() / equity_curve[0]);
  double exponent = (1.0 / yearcount);
  return (pow(base, exponent) - 1) * 100;
}

float archive::std_deviation(float* data, int len) {

  float sum = 0;
  float deviations[len];

  for(int i = 0; i < len; i++) {
    sum += data[i];
  }

  float avg = sum / len;

  for(int i = 0; i < len; i++) {
    deviations[i] = (data[i] - avg) * (data[i] - avg);
  }

  sum = 0;
  for(int i = 0; i < len; i++) {
    sum += deviations[i];
  }

  return sqrt(sum / len);
}

float archive::system_quality() {
  int len = old_positions.size();
  float rvals[len];
  float sum = 0;

  for(int i = 0; i < len; i++) {
    float risk_return = old_positions[i]->risk_return();
    rvals[i] = risk_return;
    sum += risk_return;
  }

  float avg_r = sum / len;
  float std_dev = std_deviation(rvals, len);

  if(std_dev == 0) {
    return 0;
  } else {
    return (sqrt(len) * avg_r) / std_dev;
  }
}

float archive::total_div_payout(vector<position*> cur_positions) {
  float total = 0; 

  for(int i = 0; i < old_positions.size(); i++) {
    total += old_positions[i]->div_payout();
  }

  for(int i = 0; i < cur_positions.size(); i++) {
    total += cur_positions[i]->div_payout();
  }

  return total;
}

float archive::benchmark_return() {
  float diff = ((benchmark_curve.back() - benchmark_curve.front()) / benchmark_curve.front()) * 100;
  return floor(diff * 100) / 100;
}

void archive::print_state(vector<position*> cur_positions) {
  cout << "{\"trades\":";
  cout << "[";

  vector<position*> all = old_positions;
  all.insert(all.end(), cur_positions.begin(), cur_positions.end());
  compute_basic_stats();

  for(int i = 0; i < all.size(); i++) {
    all[i]->print_state();
    if(i < all.size() - 1) {
      cout << ',';
    }
  }

  cout.setf(std::ios::fixed,std::ios::floatfield);
  cout.precision(2);
 
  cout << "],\"stops\":";
  cout << "[";

  for(int i = 0; i < all.size(); i++) {
    all[i]->print_stop_curve();
    if(i < all.size() - 1) {
      cout << ',';
    }
  }
  
  cout << "],\"equity\":[";
 
  for(int i = 0; i < equity_curve.size(); i++) {
     cout << equity_curve[i];
     if(i < equity_curve.size() - 1) {
       cout << ',';
     }
  }

  cout << "],\"stats\":{";

  cout << "\"return\": " << total_return() << ", ";
  cout << "\"equity\": " << current_equity() << ", ";
  cout << "\"winners\": " << winners << ", ";
  cout << "\"losers\": " << losers << ", ";
  cout << "\"winpercent\": " << winpercent << ", ";
  cout << "\"losepercent\": " << losepercent << ", ";
  cout << "\"avgwin\": " << avgwin << ", ";
  cout << "\"avgloss\": " << avgloss << ", ";
  cout << "\"drawdown\": " << max_drawdown() << ", ";
  cout << "\"dividends\": " << total_div_payout(cur_positions) << ", ";
  
  if(old_positions.size() > 1) {
    cout << "\"sqn\": " << system_quality() << ", ";
  }

  if(equity_curve.size() >= YEAR_SIZE) {
    cout << "\"cagr\": " << cagr() << ", ";
  }  

  if(benchmark_curve.size() > 1) {
    cout << "\"benchmark\": " << benchmark_return() << ", ";
  }

  cout << "\"expect\": " << expectancy;

  cout << "}}";
  cout << endl;
}
