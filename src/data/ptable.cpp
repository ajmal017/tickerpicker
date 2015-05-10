/* A word about the file format, here:
 * Since this is read only data with a primary key that increases in strictly 
 * monotonic fashion, there's no need for something with locking and consistency
 * features.  There's no need to incur the overhead of even the fastest nosql 
 * platforms available, so we just do straight binary reads of what is essentially
 * a simple little ISAM table.
 *
 * All values are written as 32 bit unsigned integers in network order.
 *
 * There are two headers that come before the start of the price data:
 *
 * The index starts with a single int giving the number of index records.
 * Each index record is a key/value pair, giving the year as the key and
 * the number of the row that contains the first day of data for that year.
 * This index is used by the search routines to narrow down the search and 
 * avoid sweeping the whole file.
 *
 * The second header starts with a single int giving the number of split
 * records, and stores the stock split data.  A record is a serialized 
 * date, and two ints for the before and after values.
 *
 * The last value before prices gives the number of rows in the table.
 *
 * Price data is stored in descending order, with the most recent data at
 * the start, and the oldest day of data being the last.  The data is in 
 * date/open/high/low/close/volume order.  Dates are serialized ints (easier
 * for the search routines and for compact storage), and the prices are
 * stored as fixed point data with two decimal places of precision.
 */

#include <arpa/inet.h>
#include <algorithm>
#include <iostream>
#include <utility>
#include "ptable.h"

ptable::ptable(string ticker) {
  replace(ticker.begin(), ticker.end(), '/', '-');
  symbol = ticker;
  open();
}

void ptable::open() {
  string fname = "ptabs/" + symbol + ".ptab";
  binfile.open(fname.c_str(), ios::in | ios::binary);

  if(binfile.is_open()) {
    read_index_header();
    read_splits();
    read_rowcount();
    rstart = binfile.tellg();
  } else {
    throw exception();
  }
}

pdata ptable::read(int rowcount) {
  int blocksize = rowcount * ROW_SIZE;
  uint32_t* rawdata = new uint32_t[blocksize];
  binfile.read((char *) rawdata, blocksize);
  rowcount = binfile.gcount() / ROW_SIZE;
  pdata rval = store_rows(rawdata, rowcount); 
  rval.offset = current_row();
  find_splits(&rval);
  delete[] rawdata;
  return rval;
}

pdata ptable::pull_history_by_limit(date start, int limit) {
  int datastart = find_row(start);
  find_row(datastart);
  return read(limit);
}

void ptable::pull_history_by_dates() {

}

float ptable::pull_close_on_date(date onday) {
  int target = find_row(onday);
  find_row(target);
  uint32_t row[ROW_COUNT];
  binfile.read((char *) &row, ROW_SIZE);
  return ntohl(row[CLOSE]) / SCALE;
}

void ptable::pull_dividends() {

}

pdata ptable::store_rows(uint32_t* data, int len) {
  pdata rval;

  for(int i = 0; i < len * ROW_COUNT; i += ROW_COUNT) {
    rval.date.push_back(ntohl(data[i]));
    rval.open.push_back(ntohl(data[i + OPEN]) / SCALE);
    rval.high.push_back(ntohl(data[i + HIGH]) / SCALE);
    rval.low.push_back(ntohl(data[i + LOW]) / SCALE);
    rval.close.push_back(ntohl(data[i + CLOSE]) / SCALE);
    rval.volume.push_back(ntohl(data[i + VOLUME]));
  }

  return rval;
}

void ptable::read_splits() {
  uint32_t count, data[3]; 
  binfile.read((char *) &count, UINT_BYTES);

  for(int i = 0; i < ntohl(count); i++) {
    binfile.read((char *) &data, 12);
    date d(ntohl(data[0]));
    pair<uint16_t, uint16_t> scale = std::make_pair(ntohl(data[1]), ntohl(data[2]));
    splits[d] = scale;
  }
}

void ptable::read_rowcount() {
  unsigned int temp;
  binfile.read((char *) &temp, UINT_BYTES);
  rcount = ntohl(temp);
}

int ptable::find_row(date target) {

  if(rcount == 0) {
    return 0;
  }

  std::map<uint16_t, uint32_t>::iterator it = index.find(target.getyear());
  unsigned int start, end;

  if(it == index.begin()) {
    end = rcount; 
    it++;
    start = it->second;
  } else {
    start = it->second;
    it--;
    end = it->second;
  }

  return binary_search(target.int_image(), start, end);
}

void ptable::find_row(int target) {
  binfile.seekg(rstart + (target * ROW_SIZE));
}

void ptable::read_index_header() {
  uint32_t headerlen, year, offset;
  binfile.read((char *) &headerlen, UINT_BYTES); 

  for(int i = 0; i < ntohl(headerlen); i++) {
   binfile.read((char *) &year, UINT_BYTES); 
   binfile.read((char *) &offset, UINT_BYTES); 
   index[ntohl(year)] = ntohl(offset);
  }
}

int ptable::binary_search(int key, int imin, int imax) {
  uint32_t curdate, imid;

  while (imin <= imax) {
    imid = imin + ((imax - imin)/2); 

    find_row(imid);
    binfile.read((char *) &curdate, UINT_BYTES);
    curdate = ntohl(curdate);

    if(curdate == key)
      return imid; 
    else if (curdate < key)
      imax = imid - 1;
    else         
      imin = imid + 1;
  }

  if(curdate > key) {
    return imid + 1;
  }

  return imid;
}

void ptable::find_splits(pdata* tab) {
  if(tab->size() > 0) {
    date firstday(tab->date[0]);
    date lastday(tab->date.back());
  
    std::map<date, pair<uint16_t, uint16_t> >::iterator it;
  
    for(it = splits.begin(); it != splits.end(); it++) {
      if(firstday >= it->first && lastday < it->first) {
        date thissplit = it->first;
        tab->add_split(it->first, it->second);
      }
    }
  }
}

int ptable::current_row() {
  int offset = ((int)binfile.tellg()) - rstart;
  int currow = offset / ROW_SIZE;
  return (rcount - currow) + 1; 
}
