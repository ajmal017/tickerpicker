load '../ui/cmdline/codegen.rb'

@testnumber = 1

def run_test(num, rules, expect)

  print "test #{@testnumber}:  "

  p = CodeGenerator::Parser.new(rules)
  p.parse_rules
  result = {:rules => p.table.rules, :symbols => p.table.symboltable}

  unless(result == expect)
    puts "FAILURE:"
    puts "For rules '#{rules}'"
    puts "Expected #{expect} BUT GOT #{result}" 
    puts "TEST #{@testnumber} ON LINE #{num}"
    abort
  else
    puts "OK"
    @testnumber += 1
  end
end

#simple conditions
run_test(__LINE__, "1 > 1;", {:rules=>["$0 > $0"], :symbols=>["1"]})
run_test(__LINE__, "C > 1;", {:rules=>["$0 > $1"], :symbols=>["C", "1"]})
run_test(__LINE__, "C > C;", {:rules=>["$0 > $0"], :symbols=>["C"]})

run_test(__LINE__, "1 < 1;", {:rules=>["$0 < $0"], :symbols=>["1"]})
run_test(__LINE__, "C < 1;", {:rules=>["$0 < $1"], :symbols=>["C", "1"]})
run_test(__LINE__, "C < C;", {:rules=>["$0 < $0"], :symbols=>["C"]})

run_test(__LINE__, "1 >= 1;", {:rules=>["$0 >= $0"], :symbols=>["1"]})
run_test(__LINE__, "C >= 1;", {:rules=>["$0 >= $1"], :symbols=>["C", "1"]})
run_test(__LINE__, "C >= C;", {:rules=>["$0 >= $0"], :symbols=>["C"]})

run_test(__LINE__, "1 <= 1;", {:rules=>["$0 <= $0"], :symbols=>["1"]})
run_test(__LINE__, "C <= 1;", {:rules=>["$0 <= $1"], :symbols=>["C", "1"]})
run_test(__LINE__, "C <= C;", {:rules=>["$0 <= $0"], :symbols=>["C"]})

run_test(__LINE__, "1 != 1;", {:rules=>["$0 != $0"], :symbols=>["1"]})
run_test(__LINE__, "C != 1;", {:rules=>["$0 != $1"], :symbols=>["C", "1"]})
run_test(__LINE__, "C != C;", {:rules=>["$0 != $0"], :symbols=>["C"]})

run_test(__LINE__, "1 = 1;", {:rules=>["$0 = $0"], :symbols=>["1"]})
run_test(__LINE__, "C = 1;", {:rules=>["$0 = $1"], :symbols=>["C", "1"]})
run_test(__LINE__, "C = C;", {:rules=>["$0 = $0"], :symbols=>["C"]})

#simple conditions with an argument to the indicator
run_test(__LINE__, "C1 > 1;", {:rules=>["$1 > $0"], :symbols=>["1", "C $0"]})
run_test(__LINE__, "C1 > C;", {:rules=>["$1 > $2"], :symbols=>["1", "C $0", "C"]})
run_test(__LINE__, "C1 > C1;", {:rules=>["$1 > $1"], :symbols=>["1", "C $0"]})

run_test(__LINE__, "C1 < 1;", {:rules=>["$1 < $0"], :symbols=>["1", "C $0"]})
run_test(__LINE__, "C1 < C;", {:rules=>["$1 < $2"], :symbols=>["1", "C $0", "C"]})
run_test(__LINE__, "C1 < C1;", {:rules=>["$1 < $1"], :symbols=>["1", "C $0"]})

run_test(__LINE__, "C1 >= 1;", {:rules=>["$1 >= $0"], :symbols=>["1", "C $0"]})
run_test(__LINE__, "C1 >= C;", {:rules=>["$1 >= $2"], :symbols=>["1", "C $0", "C"]})
run_test(__LINE__, "C1 >= C1;", {:rules=>["$1 >= $1"], :symbols=>["1", "C $0"]})

run_test(__LINE__, "C1 <= 1;", {:rules=>["$1 <= $0"], :symbols=>["1", "C $0"]})
run_test(__LINE__, "C1 <= C;", {:rules=>["$1 <= $2"], :symbols=>["1", "C $0", "C"]})
run_test(__LINE__, "C1 <= C1;", {:rules=>["$1 <= $1"], :symbols=>["1", "C $0"]})

run_test(__LINE__, "C1 = 1;", {:rules=>["$1 = $0"], :symbols=>["1", "C $0"]})
run_test(__LINE__, "C1 = C;", {:rules=>["$1 = $2"], :symbols=>["1", "C $0", "C"]})
run_test(__LINE__, "C1 = C1;", {:rules=>["$1 = $1"], :symbols=>["1", "C $0"]})

run_test(__LINE__, "C1 != 1;", {:rules=>["$1 != $0"], :symbols=>["1", "C $0"]})
run_test(__LINE__, "C1 != C;", {:rules=>["$1 != $2"], :symbols=>["1", "C $0", "C"]})
run_test(__LINE__, "C1 != C1;", {:rules=>["$1 != $1"], :symbols=>["1", "C $0"]})

#simple conditions with more than one argument to the indicator
run_test(__LINE__, "C1,2 > 1;", {:rules=>["$2 > $0"], :symbols=>["1", "2", "C $0,$1"]})
run_test(__LINE__, "C1,2 > C;", {:rules=>["$2 > $3"], :symbols=>["1", "2", "C $0,$1", "C"]})
run_test(__LINE__, "C1,2 > C1;", {:rules=>["$2 > $3"], :symbols=>["1", "2", "C $0,$1", "C $0"]})

#simple conditions with more than one argument to both indicators
run_test(__LINE__, "C1,2 > C1,2;", {:rules=>["$2 > $2"], :symbols=>["1", "2", "C $0,$1"]})
run_test(__LINE__, "C1,1 > C2,2;", {:rules=>["$1 > $3"], :symbols=>["1", "C $0,$0", "2", "C $2,$2"]})
run_test(__LINE__, "C1,2 > C3,4;", {:rules=>["$2 > $5"], :symbols=>["1", "2", "C $0,$1", "3", "4", "C $3,$4"]})

#simple conditions with more than one argument to the indicator
#and a parenthesized argument list
run_test(__LINE__, "C(1,2) > 1;", {:rules=>["$2 > $0"], :symbols=>["1", "2", "C $0,$1"]})
run_test(__LINE__, "C(1,2) > C;", {:rules=>["$2 > $3"], :symbols=>["1", "2", "C $0,$1", "C"]})
run_test(__LINE__, "C(1,2) > C(1);", {:rules=>["$2 > $3"], :symbols=>["1", "2", "C $0,$1", "C $0"]})

#simple conditions with more than one argument to both indicators
#and a parenthesized argument list
run_test(__LINE__, "C(1,2) > C(1,2);", {:rules=>["$2 > $2"], :symbols=>["1", "2", "C $0,$1"]})
run_test(__LINE__, "C(1,1) > C(2,2);", {:rules=>["$1 > $3"], :symbols=>["1", "C $0,$0", "2", "C $2,$2"]})
run_test(__LINE__, "C(1,2) > C(3,4);", {:rules=>["$2 > $5"], :symbols=>["1", "2", "C $0,$1", "3", "4", "C $3,$4"]})
run_test(__LINE__, "C((1),(2),(3)) > 1;", {:rules=>["$3 > $0"], :symbols=>["1", "2", "3", "C $0,$1,$2"]})
run_test(__LINE__, "C((1),(2),(3)) > C((1),(2),(3));", {:rules=>["$3 > $3"], :symbols=>["1", "2", "3", "C $0,$1,$2"]})

#nested indicators
run_test(__LINE__, "ABS(C) > 1;", {:rules=>["$1 > $2"], :symbols=>["C", "ABS $0", "1"]})
run_test(__LINE__, "ABS(C) > ABS(C1);", {:rules=>["$1 > $4"], :symbols=>["C", "ABS $0", "1", "C $2", "ABS $3"]})
run_test(__LINE__, "ABS(C) > ABS(C(1));", {:rules=>["$1 > $4"], :symbols=>["C", "ABS $0", "1", "C $2", "ABS $3"]})
run_test(__LINE__, "ABS(ABS(ABS(C(1,1)))) > 0;", {:rules=>["$4 > $5"], :symbols=>["1", "C $0,$0", "ABS $1", "ABS $2", "ABS $3", "0"]})
run_test(__LINE__, "ABS(ABS(ABS(C((1),1)))) > 0;", {:rules=>["$4 > $5"], :symbols=>["1", "C $0,$0", "ABS $1", "ABS $2", "ABS $3", "0"]})
run_test(__LINE__, "ABS(ABS(ABS(C((1),(1))))) > 0;", {:rules=>["$4 > $5"], :symbols=>["1", "C $0,$0", "ABS $1", "ABS $2", "ABS $3", "0"]})

#basic expressions
run_test(__LINE__, "1+1 = 1+1;", {:rules=>["$1 = $1"], :symbols=>["1", "$0 + $0"]})
run_test(__LINE__, "1+1 = 2+2;", {:rules=>["$1 = $3"], :symbols=>["1", "$0 + $0", "2", "$2 + $2"]})
run_test(__LINE__, "1+1+1 = 1+1;", {:rules=>["$2 = $1"], :symbols=>["1", "$0 + $0", "$0 + $1"]})
run_test(__LINE__, "1+1+1 = 2+2+2;", {:rules=>["$2 = $5"], :symbols=>["1", "$0 + $0", "$0 + $1", "2", "$3 + $3", "$3 + $4"]})

run_test(__LINE__, "1-1 = 1+1;", {:rules=>["$1 = $2"], :symbols=>["1", "$0 - $0", "$0 + $0"]})
run_test(__LINE__, "1-1 = 2+2;", {:rules=>["$1 = $3"], :symbols=>["1", "$0 - $0", "2", "$2 + $2"]})
run_test(__LINE__, "1-1+1 = 1+1;", {:rules=>["$2 = $1"], :symbols=>["1", "$0 + $0", "$0 - $1"]})
run_test(__LINE__, "1-1+1 = 2+2+2;", {:rules=>["$2 = $5"], :symbols=>["1", "$0 + $0", "$0 - $1", "2", "$3 + $3", "$3 + $4"]})

run_test(__LINE__, "C + 1 = 1;", {:rules=>["$2 = $1"], :symbols=>["C", "1", "$0 + $1"]})
run_test(__LINE__, "C + 1 = C;", {:rules=>["$2 = $0"], :symbols=>["C", "1", "$0 + $1"]})
run_test(__LINE__, "C + 1 = C + 1;", {:rules=>["$2 = $2"], :symbols=>["C", "1", "$0 + $1"]})
run_test(__LINE__, "C + 1 = C - 1;", {:rules=>["$2 = $3"], :symbols=>["C", "1", "$0 + $1", "$0 - $1"]})

run_test(__LINE__, "(1)+(1) = (1)+(1);", {:rules=>["$1 = $1"], :symbols=>["1", "$0 + $0"]})
run_test(__LINE__, "C1 + 1 = 1;", {:rules=>["$2 = $0"], :symbols=>["1", "C $0", "$1 + $0"]})
run_test(__LINE__, "C1 + 1 = C;", {:rules=>["$2 = $3"], :symbols=>["1", "C $0", "$1 + $0", "C"]})
run_test(__LINE__, "C1 + 1 = C + 1;", {:rules=>["$2 = $4"], :symbols=>["1", "C $0", "$1 + $0", "C", "$3 + $0"]})
run_test(__LINE__, "C1 + 1 = C - 1;", {:rules=>["$2 = $4"], :symbols=>["1", "C $0", "$1 + $0", "C", "$3 - $0"]})

run_test(__LINE__, "C1 + 1 + 1 = 1;", {:rules=>["$3 = $0"], :symbols=>["1", "C $0", "$0 + $0", "$1 + $2"]})
run_test(__LINE__, "C1 + 2 + 3 = 4;", {:rules=>["$5 = $6"], :symbols=>["1", "C $0", "2", "3", "$2 + $3", "$1 + $4", "4"]})

#ternary operator
run_test(__LINE__, "{0 > 1 ? 0 : 1} = 1;", {:rules=>["$3 = $1"], :symbols=>["0", "1", "$0 > $1", "$2 $0 $1"]})
run_test(__LINE__, "{0 > 1 ? 2 : 3} = 4;", {:rules=>["$5 = $6"], :symbols=>["0", "1", "$0 > $1", "2", "3", "$2 $3 $4", "4"]})
run_test(__LINE__, "{0 > 1 ? 0 : 1} = {0 < 1 ? 1 : 0};", {:rules=>["$3 = $5"], :symbols=>["0", "1", "$0 > $1", "$2 $0 $1", "$0 < $1", "$4 $1 $0"]})
run_test(__LINE__, "{1 = 1 ? 0 : {1 != 1 ? 2 : 3}} > 0;", {:rules=>["$7 > $2"], :symbols=>["1", "$0 = $0", "0", "$0 != $0", "2", "3", "$3 $4 $5", "$1 $2 $6"]})
run_test(__LINE__, "{1 = 1 ? 0 : {1 != 1 ? 2 : 3}} = {1 = 1 ? 0 : {1 != 1 ? 2 : 3}};", {:rules=>["$7 = $7"], :symbols=>["1", "$0 = $0", "0", "$0 != $0", "2", "3", "$3 $4 $5", "$1 $2 $6"]})
run_test(__LINE__, "{1 = 1 ? {2 = 2 ? 0 : 1} : {3 = 3 ? 0 : 1}} = 1;", {:rules=>["$9 = $0"], :symbols=>["1", "$0 = $0", "2", "$2 = $2", "0", "$3 $4 $0", "3", "$6 = $6", "$7 $4 $0", "$1 $5 $8"]})
run_test(__LINE__, "{0 > 1 ? 2 : 3} = {0 > 1 ? 2 : 3};", {:rules=>["$5 = $5"], :symbols=>["0", "1", "$0 > $1", "2", "3", "$2 $3 $4"]})
run_test(__LINE__, "{0 > 1 ? 2 : 3} + 4 > 6;", {:rules=>["$7 > $8"], :symbols=>["0", "1", "$0 > $1", "2", "3", "$2 $3 $4", "4", "$5 + $6", "6"]})

#indicators and ternary operator
run_test(__LINE__, "C({0 > 1 ? 0 : 1}) > 0;", {:rules=>["$4 > $0"], :symbols=>["0", "1", "$0 > $1", "$2 $0 $1", "C $3"]})
run_test(__LINE__, "C(5,{0 > 1 ? 0 : 1}) > 0;", {:rules=>["$5 > $1"], :symbols=>["5", "0", "1", "$1 > $2", "$3 $1 $2", "C $0,$4"]})
run_test(__LINE__, "C({0 > 1 ? 0 : 1},{1 > 2 ? 1 : 2}) > 1;", {:rules=>["$7 > $1"], :symbols=>["0", "1", "$0 > $1", "$2 $0 $1", "2", "$1 > $4", "$5 $1 $4", "C $3,$6"]})
run_test(__LINE__, "C({0 > 1 ? 2 : 3},{0 > 1 ? 2 : 3}) > 5;", {:rules=>["$6 > $7"], :symbols=>["0", "1", "$0 > $1", "2", "3", "$2 $3 $4", "C $5,$5", "5"]})
run_test(__LINE__, "C({0 > 1 ? 2 : {3 > 4 ? 5 : 6}}) > 0;", {:rules=>["$11 > $0"], :symbols=>["0", "1", "$0 > $1", "2", "3", "4", "$4 > $5", "5", "6", "$6 $7 $8", "$2 $3 $9", "C $10"]})
run_test(__LINE__, "C({0 > 1 ? 2 : 3},5,C3) > 5;", {:rules=>["$8 > $6"], :symbols=>["0", "1", "$0 > $1", "2", "3", "$2 $3 $4", "5", "C $4", "C $5,$6,$7"]})

#associativity
run_test(__LINE__, "1+1+1+1>1;", {:rules=>["$3 > $0"], :symbols=>["1", "$0 + $0", "$0 + $1", "$0 + $2"]})
run_test(__LINE__, "1*1*1*1>1;", {:rules=>["$3 > $0"], :symbols=>["1", "$0 * $0", "$0 * $1", "$0 * $2"]})

run_test(__LINE__, "(1+(1+(1+1))) > 1;", {:rules=>["$3 > $0"], :symbols=>["1", "$0 + $0", "$0 + $1", "$0 + $2"]})
run_test(__LINE__, "(1*(1*(1*1))) > 1;", {:rules=>["$3 > $0"], :symbols=>["1", "$0 * $0", "$0 * $1", "$0 * $2"]})

run_test(__LINE__, "(((1+1)+1)+1) > 1;", {:rules=>["$3 > $0"], :symbols=>["1", "$0 + $0", "$1 + $0", "$2 + $0"]})
run_test(__LINE__, "(((1*1)*1)*1) > 1;", {:rules=>["$3 > $0"], :symbols=>["1", "$0 * $0", "$1 * $0", "$2 * $0"]})

run_test(__LINE__, "1+2+3 > 4;", {:rules=>["$4 > $5"], :symbols=>["1", "2", "3", "$1 + $2", "$0 + $3", "4"]})
run_test(__LINE__, "1*2*3 > 4;", {:rules=>["$4 > $5"], :symbols=>["1", "2", "3", "$1 * $2", "$0 * $3", "4"]})

run_test(__LINE__, "(1+(2+3)) > 4;", {:rules=>["$4 > $5"], :symbols=>["1", "2", "3", "$1 + $2", "$0 + $3", "4"]})
run_test(__LINE__, "(1*(2*3)) > 4;", {:rules=>["$4 > $5"], :symbols=>["1", "2", "3", "$1 * $2", "$0 * $3", "4"]})

run_test(__LINE__, "((1+2)+3) > 4;", {:rules=>["$4 > $5"], :symbols=>["1", "2", "$0 + $1", "3", "$2 + $3", "4"]})
run_test(__LINE__, "((1*2)*3) > 4;", {:rules=>["$4 > $5"], :symbols=>["1", "2", "$0 * $1", "3", "$2 * $3", "4"]})

#floating point numbers
run_test(__LINE__, "1.0 > 1;", {:rules=>["$0 > $1"], :symbols=>["1.0", "1"]})
run_test(__LINE__, "1.0 > 2.0;", {:rules=>["$0 > $1"], :symbols=>["1.0", "2.0"]})
run_test(__LINE__, ".1 > 1;", {:rules=>["$0 > $1"], :symbols=>[".1", "1"]})
run_test(__LINE__, ".1 > .2;", {:rules=>["$0 > $1"], :symbols=>[".1", ".2"]})
run_test(__LINE__, "1 + .1 > 1;", {:rules=>["$2 > $0"], :symbols=>["1", ".1", "$0 + $1"]})
run_test(__LINE__, "1 + 0.1 > 1;", {:rules=>["$2 > $0"], :symbols=>["1", "0.1", "$0 + $1"]})
run_test(__LINE__, "1.0 + .1 > 1;", {:rules=>["$2 > $3"], :symbols=>["1.0", ".1", "$0 + $1", "1"]})
run_test(__LINE__, "1.0 + 0.1 > 1;", {:rules=>["$2 > $3"], :symbols=>["1.0", "0.1", "$0 + $1", "1"]})

#test AND/OR/XOR
run_test(__LINE__, "C > 1 OR C < 0;", {:rules=>["$2 OR $4"], :symbols=>["C", "1", "$0 > $1", "0", "$0 < $3"]})
run_test(__LINE__, "C > 1 XOR C < 0;", {:rules=>["$2 XOR $4"], :symbols=>["C", "1", "$0 > $1", "0", "$0 < $3"]})
run_test(__LINE__, "C > 1 AND C < 0;", {:rules=>["$2 AND $4"], :symbols=>["C", "1", "$0 > $1", "0", "$0 < $3"]})
run_test(__LINE__, "C > 1 OR C > 2 OR C > 3 OR C > 5;", {:rules=>["$2 OR $10"], :symbols=>["C", "1", "$0 > $1", "2", "$0 > $3", "3", "$0 > $5", "5", "$0 > $7", "$6 OR $8", "$4 OR $9"]})
run_test(__LINE__, "C > 1 XOR C > 2 XOR C > 3 XOR C > 5;", {:rules=>["$2 XOR $10"], :symbols=>["C", "1", "$0 > $1", "2", "$0 > $3", "3", "$0 > $5", "5", "$0 > $7", "$6 XOR $8", "$4 XOR $9"]})
run_test(__LINE__, "C > 1 AND C > 2 AND C > 3 AND C > 5;", {:rules=>["$2 AND $10"], :symbols=>["C", "1", "$0 > $1", "2", "$0 > $3", "3", "$0 > $5", "5", "$0 > $7", "$6 AND $8", "$4 AND $9"]})

#compound AND/OR/XOR
run_test(__LINE__, "C20 >= 5 AND (AVGC20 * AVGV20) >= 250000 AND 100 * (C - C20) / C20 >= 5;", {:rules=>["$3 AND $15"], :symbols=>["20", "C $0", "5", "$1 >= $2", "AVGC $0", "AVGV $0", "$4 * $5", "250000", "$6 >= $7", "100", "C", "$10 - $1", "$11 / $1", "$9 * $12", "$13 >= $2", "$8 AND $14"]})
run_test(__LINE__, "( 100 * (C - C1) / C1) >= 20 AND V > 10000 AND C >= 5;", {:rules=>["$8 AND $14"], :symbols=>["100", "C", "1", "C $2", "$1 - $3", "$4 / $3", "$0 * $5", "20", "$6 >= $7", "V", "10000", "$9 > $10", "5", "$1 >= $12", "$11 AND $13"]})
run_test(__LINE__, "(100 * (C - C1) / C1) >= 4 AND V >= 1000 AND V > V1;", {:rules=>["$8 AND $14"], :symbols=>["100", "C", "1", "C $2", "$1 - $3", "$4 / $3", "$0 * $5", "4", "$6 >= $7", "V", "1000", "$9 >= $10", "V $2", "$9 > $12", "$11 AND $13"]})
run_test(__LINE__, "(C - C1) >= 5 AND V > 10000 AND C >= 5;", {:rules=>["$5 AND $10"], :symbols=>["C", "1", "C $1", "$0 - $2", "5", "$3 >= $4", "V", "10000", "$6 > $7", "$0 >= $4", "$8 AND $9"]})
run_test(__LINE__, "C > C1 AND V > 5 * AVGV50.1 AND V > 3000 AND C > 5;", {:rules=>["$3 AND $14"], :symbols=>["C", "1", "C $1", "$0 > $2", "V", "5", "50.1", "AVGV $6", "$5 * $7", "$4 > $8", "3000", "$4 > $10", "$0 > $5", "$11 AND $12", "$9 AND $13"]})

#negative numbers and clists
run_test(__LINE__, "-1 > -2;", {:rules=>["$0 > $1"], :symbols=>["-1", "-2"]})
run_test(__LINE__, "C - 1 = 1;", {:rules=>["$2 = $1"], :symbols=>["C", "1", "$0 - $1"]})
run_test(__LINE__, "C - -1 = 1;", {:rules=>["$2 = $3"], :symbols=>["C", "-1", "$0 - $1", "1"]})
run_test(__LINE__, "C - (-1) = 1;", {:rules=>["$2 = $3"], :symbols=>["C", "-1", "$0 - $1", "1"]})
run_test(__LINE__, "C(1,2,-1) > 1;", {:rules=>["$3 > $0"], :symbols=>["1", "2", "-1", "C $0,$1,$2"]})
run_test(__LINE__, "C(-1) = C(-1);", {:rules=>["$1 = $1"], :symbols=>["-1", "C $0"]})
run_test(__LINE__, "C(-1) = C - 1;", {:rules=>["$1 = $4"], :symbols=>["-1", "C $0", "C", "1", "$2 - $3"]})
run_test(__LINE__, "( 100 * (C - C1) / C1) <= ( - 20) AND V > 10000 AND C >= 5;", {:rules=>["$8 AND $14"], :symbols=>["100", "C", "1", "C $2", "$1 - $3", "$4 / $3", "$0 * $5", "-20", "$6 <= $7", "V", "10000", "$9 > $10", "5", "$1 >= $12", "$11 AND $13"]})
run_test(__LINE__, "( 100 * (C - C1) / C1) <= ( - 30) AND V > 3000 AND C >= 5;", {:rules=>["$8 AND $14"], :symbols=>["100", "C", "1", "C $2", "$1 - $3", "$4 / $3", "$0 * $5", "-30", "$6 <= $7", "V", "3000", "$9 > $10", "5", "$1 >= $12", "$11 AND $13"]})
run_test(__LINE__, "(C - C1) <= ( - 5) AND V > 10000 AND C >= 5;", {:rules=>["$5 AND $11"], :symbols=>["C", "1", "C $1", "$0 - $2", "-5", "$3 <= $4", "V", "10000", "$6 > $7", "5", "$0 >= $9", "$8 AND $10"]})
run_test(__LINE__, "( 100 * (C - C1) / C1) <= ( - 10) AND V > 1000 AND C >= 5;", {:rules=>["$8 AND $14"], :symbols=>["100", "C", "1", "C $2", "$1 - $3", "$4 / $3", "$0 * $5", "-10", "$6 <= $7", "V", "1000", "$9 > $10", "5", "$1 >= $12", "$11 AND $13"]})

#some general tests
run_test(__LINE__, "BOLLINGER_UPPER20,2 > BOLLINGER_LOWER20,2;", {:rules=>["$2 > $3"], :symbols=>["20", "2", "BOLLINGER_UPPER $0,$1", "BOLLINGER_LOWER $0,$1"]})
run_test(__LINE__, "(((C - MINC260) / MINC260) * 100) > 100;", {:rules=>["$6 > $5"], :symbols=>["C", "260", "MINC $1", "$0 - $2", "$3 / $2", "100", "$4 * $5"]})
run_test(__LINE__, "(100 * ((C - C250) / C250)) >= 300;", {:rules=>["$6 >= $7"], :symbols=>["100", "C", "250", "C $2", "$1 - $3", "$4 / $3", "$0 * $5", "300"]})
run_test(__LINE__, "(100 * ((MAXC250 - MINC250) / MINC250)) >= 400;", {:rules=>["$6 >= $7"], :symbols=>["100", "250", "MAXC $1", "MINC $1", "$2 - $3", "$4 / $3", "$0 * $5", "400"]})
run_test(__LINE__, "(100 * ((C + .01) - (MAXC34 + .01)) / (MAXC34 + .01)) > 1;", {:rules=>["$9 > $10"], :symbols=>["100", "C", ".01", "$1 + $2", "34", "MAXC $4", "$5 + $2", "$3 - $6", "$7 / $6", "$0 * $8", "1"]})
run_test(__LINE__, "(((MAXC260 - C) / MAXC260) * 100) <= 25;", {:rules=>["$6 <= $7"], :symbols=>["260", "MAXC $0", "C", "$1 - $2", "$3 / $1", "100", "$4 * $5", "25"]})
run_test(__LINE__, "(((C - MINC260) / MINC260) * 100) > 100;", {:rules=>["$6 > $5"], :symbols=>["C", "260", "MINC $1", "$0 - $2", "$3 / $2", "100", "$4 * $5"]})
run_test(__LINE__, "DAYCHANGE >= 10;", {:rules=>["$0 >= $1"], :symbols=>["DAYCHANGE", "10"]})
run_test(__LINE__, "((ATR20 / AVGC20) * 100) <= 2;", {:rules=>["$5 <= $6"], :symbols=>["20", "ATR $0", "AVGC $0", "$1 / $2", "100", "$3 * $4", "2"]})
run_test(__LINE__, "(ATR20 / AVGC20) * 100 <= 2;", {:rules=>["$5 <= $6"], :symbols=>["20", "ATR $0", "AVGC $0", "$1 / $2", "100", "$3 * $4", "2"]})
run_test(__LINE__, "100 * ((C + .01) - ( MINC65 + .01)) / (MINC65 + .01) >= 25 AND AVGC20 * AVGV20 >= 2500;", {:rules=>["$11 AND $17"], :symbols=>["100", "C", ".01", "$1 + $2", "65", "MINC $4", "$5 + $2", "$3 - $6", "$7 / $6", "$0 * $8", "25", "$9 >= $10", "20", "AVGC $12", "AVGV $12", "$13 * $14", "2500", "$15 >= $16"]})

#more bad threeopcode
run_test(__LINE__, "C(1,2,C) != C;", {:rules=>["$3 != $2"], :symbols=>["1", "2", "C", "C $0,$1,$2"]})
run_test(__LINE__, "C(0,1+1,2) > 3;", {:rules=>["$4 > $5"], :symbols=>["0", "1", "$1 + $1", "2", "C $0,$2,$3", "3"]})
run_test(__LINE__, "C({0 > 1 ? 2 : 3} + 4) > C1;", {:rules=>["$8 > $9"], :symbols=>["0", "1", "$0 > $1", "2", "3", "$2 $3 $4", "4", "$5 + $6", "C $7", "C $1"]})


#COMPOUND STATEMENTS
#run_test(__LINE__, "C > 1; O > 2;", {})
#run_test(__LINE__, "C > 1; O > 2; H > 4; L > 5;", {})


#run_test(__LINE__, "(C > C1) AND (C > AVGC50) AND (AVGC50 > AVGC200) AND (V > 1.5 * AVGV50) AND (AVGV50 >= 200) AND (C > 4);", {})
#{1 > 1 OR 2 > 2 ? 0 : 1} > 0;
#run_test(__LINE__, "{C > 1 OR C > 2 ? 0 : 1} > 1;", {})
