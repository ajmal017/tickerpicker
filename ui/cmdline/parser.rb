require_relative 'code'
#Grammar

#rule -> boolean | boolean or rule;
#boolean -> expression compare expression 
#expression -> (expression) exprest | value exprest
#exprest -> allops expression exprest | epsilon
#value -> indicator | ternary | constant
#indicator -> macro clist | macro(arglist) | macro
#ternary -> {boolean ? expression : expression}
#arglist -> expression | expression,arglist
#clist -> constant | constant,clist

#Terminal Productions

#compare -> = != < > >= <=
#macro -> one of the indicator macros
#constant -> do I really need to explain?
#allops -> +- * % /
#plusminus -> + -
#op -> * % /

class Parser

  MACROS = %w(V O H L C MINV MINO MINH MINL MINC MAXV MAXO MAXH MAXL MAXC AVGV AVGO AVGH AVGL AVGC EMAV EMAO EMAH EMAL 
  EMAC WMAV WMAO WMAH WMAL WMAC STOCH_FAST_D STOCH_FAST_K CURRENT_RATIO CDL_BULL_MARUBOZU CMO MAX_UP_DAY MAX_DOWN_DAY
  COM_CHAN_INDEX CDL_BEAR_MARUBOZU CDL_BULL_SPINNING_TOP CDL_BEAR_SPINNING_TOP CDL_DOJI CDL_DRAGONFLY CDL_GRAVESTONE 
  OBV CDL_HAMMER CDL_HANGMAN CDL_INVERTED_HAMMER CDL_SHOOTING_STAR EPS_TTM REVENUE_TTM NET_INCOME_TTM ROE EPS SAR 
  EARNINGS_GROWTH STRENGTH MCAP FLOAT BOLLINGER_UPPER BOLLINGER_LOWER RSI WILLIAMS_R ATR MACDS MACDH MACD MOMENTUM ROC
  BOP ADXR ADX ACCELERATION_UPPER ACCELERATION_LOWER ULTOSC ADXR ADX AROON_UP AROON_DOWN AROON_OSC EFFICIENCY_RATIO 
  TD_COMBO_BUY TD_COMBO_SELL TD_SEQUENTIAL_BUY TD_SEQUENTIAL_SELL TD_SETUP_SELL TD_SETUP_BUY PPO KELTNER_LOWER KELTNER_UPPER 
  MFI STD_DEV ROA REV_PERSHARE PROFIT_MARGIN BOOK_PERSHARE TOTAL_ASSETS CURRENT_ASSETS TOTAL_DEBT CURRENT_DEBT CASH EQUITY 
  NET_INCOME REVENUE STRENGTH TRENDSCORE RWI_LOW RWI_HIGH DIVIDEND_YIELD PRICE_EARNINGS DISCOUNTED_CASH_FLOW TREND_INTENSITY 
  PAYOUT_RATIO ULCER_INDEX RAVI POSITION_DAYS_HELD POSITION_RETURN_PERCENT POSITION_RETURN_R POSITION_SHARE_COUNT POSITION_BUY_PRICE 
  POSITION_SELL_PRICE POSITION_STOP DAYCHANGE SHARES_OUTSTANDING RAND DATE_MAX_C DATE_MIN_C ABS DAYS_AGO FRACTAL_RATIO
  STARC_UPPER STARC_LOWER PIVOT PIVOT_S PIVOT_R MAX MIN)

  OPERATOR = %w(+ - / * %)
  COMPARE = %w(= <= >= != < >)
  GROUPING = ['(', ')', ';', '?', ':', ',', '{', '}', 'OR', 'AND', 'XOR']
  TOKENS = GROUPING + OPERATOR + COMPARE + MACROS

  attr_reader :table

  def initialize(rawdata)
    @stack = []
    @tokens = []
    @table = ThreeTable.new()

    lines = rawdata.split("\n");
    lines.reject! {|l| l.strip.empty? || l.strip.start_with?('#')}

    lines.each do |line|
      @tokens.concat tokenize(line.upcase)
    end
  end

  def parse_rules
    while(!@tokens.empty?)
      parse_rule() 
      @table.addrule(@stack.pop)
    end
  end

private

  def next_const(line)
    if(line =~ /(-?[0-9]*\.?[0-9]+)/)
      num = $1
      line = line[num.length..-1]
      return num
    end
  
    abort('error tokenizing constant')
  end

  def next_token(line)
    line.lstrip!
    t = TOKENS.select {|token| line.start_with?(token)}
    t = (t.empty? ? next_const(line) : t.first)
    line.sub!(t, '')
    t
  end

  def tokenize(line)
    tokens = []
    tokens << next_token(line)

    while(tokens.last != ';')
      tokens << next_token(line)
    end
 
    tokens 
  end

  def token_is(t)
    if(@tokens.first == t)
      @last_token = @tokens.shift
      true
    else
      false
    end
  end

#rule -> boolean; | boolean or rule
  def parse_rule
    ast_prologue('rule')
    if(parse_boolean())
      if(token_is('AND') || token_is('OR') || token_is('XOR'))
        @stack.last.token = @last_token
        return ast(parse_rule())
      end
      return token_is(';')
    end 
    abort('error parsing rule')
  end

#boolean -> expression compare expression 
  def parse_boolean
    ast_prologue('boolean')
    if(parse_expression())
      if(parse_compare())
        return ast(parse_expression())
      end
    end
    abort('error parsing boolean')
  end

#expression -> (expression) exprest | value exprest
  def parse_expression
    ast_prologue('expression')
    if(token_is('('))
      if(parse_expression())
        if(token_is(')'))
          return ast(parse_exprest())
        end
      end
    end

    if(parse_value())
      return ast(parse_exprest())
    end

    ast(false)
  end

#exprest -> allops expression exprest | epsilon
  def parse_exprest
    ast_prologue('exprest')
    if(parse_allops())
      if(parse_expression())
        return ast(parse_exprest())
      end
    end
    ast(true)
  end

#value -> indicator | ternary | constant
  def parse_value
    ast_prologue('value')
    ast((parse_indicator() || parse_ternary() || parse_constant()))
  end

#indicator -> macro clist | macro(arglist) | macro
  def parse_indicator
    ast_prologue('indicator')
#binding.pry
    if(parse_macro())
      if(token_is('('))
        return ast(parse_arglist() && token_is(')'))
      end

      if(parse_clist())
        return ast(true) 
      end

      return ast(true)
    end
    ast(false)
  end

#ternary -> {boolean ? expression : expression}
  def parse_ternary
    ast_prologue('ternary')
    if(token_is('{'))
      if(parse_boolean())
        if(token_is('?'))
          if(parse_expression())
            if(token_is(':'))
              if(parse_expression())
                return ast(token_is('}'))
              end
            end
          end
        end
      end
    end
    ast(false)
  end

#arglist -> expression | expression,arglist
  def parse_arglist
    ast_prologue('arglist')
    if(parse_expression())
      return ast(parse_arglist()) if(token_is(','))
    else
      return ast(false)
    end
    return ast(true)
  end

#clist -> constant | constant,clist
  def parse_clist
    ast_prologue('clist')
    if(parse_constant())
      return ast(parse_clist()) if(token_is(','))
    else
      return ast(false)
    end
    return ast(true)
  end

  def parse_compare
    ast_prologue('compare')
    ast(COMPARE.detect {|c| token_is(c)})
  end

  def parse_allops
    ast_prologue('allops')
    ast(OPERATOR.detect {|o| token_is(o)})
  end

  def parse_constant
    ast_prologue('constant')
    if(@tokens.first =~ /([0-9]*\.?[0-9]+)/)
      return ast(@tokens.shift)
    end
    ast(false)
  end

  def parse_macro
    ast_prologue('macro')
    ast(MACROS.detect {|macro| token_is(macro)})
  end

  def ast(val)

    if(val)
      @stack.last.token = val unless(val.is_a? TrueClass)
      node = @stack.pop
      @stack.last.add_children(node)
    else
      @stack.pop
    end

    val
  end

  def ast_prologue(p)
    @stack.push(ASTNode.new(p))
  end
end
