require 'pry-debugger'
module CodeGenerator

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
  
    MACROS = %w(FLOOR CEIL ROUND RAND OBV MINV MINO MINH MINL MINC MAXV MAXO MAXH MAXL MAXC AVGV AVGO 
    AVGH AVGL AVGC EMAV EMAO EMAH EMAL EMAC WMAV WMAO WMAH WMAL WMAC SAR ROC STRENGTH BOLLINGER_UPPER BOLLINGER_LOWER 
    RSI WILLIAMS_R ATR MACDS MACDH MACD MOMENTUM BOP ADXR ADX ACCELERATION_UPPER ACCELERATION_LOWER ULTOSC AGE
    AROON_UP AROON_DOWN AROON_OSC PPO KELTNER_LOWER KELTNER_UPPER MFI STD_DEV ROA CASH EQUITY TRENDSCORE RWI_LOW 
    RWI_HIGH DIVIDEND_YIELD TREND_INTENSITY PAYOUT_RATIO ULCER_INDEX RAVI POSITION_DAYS_HELD POSITION_RETURN_PERCENT 
    POSITION_RETURN_R POSITION_SHARE_COUNT POSITION_BUY_PRICE POSITION_SELL_PRICE POSITION_STOP DAYCHANGE DATE_MAX_C 
    PORTFOLIO_POSITION_COUNT PORTFOLIO_EQUITY PORTFOLIO_CASH PORTFOLIO_RETURN DATE_MIN_C ABS DAYS_AGO PIVOT PIVOT_S 
    PIVOT_R MAX MIN NATR V O H L C)
  
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

    def parse_exp
      ast_prologue('expression')
      parse_expression()
      @stack.first.children.first.collapse!
      @table.generate(@stack.first.children.first)
    end

  private
  
    def next_const(line)
      if(line =~ /(-?[0-9|_]*\.?[0-9|_]+)/)
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

      until(line.empty?)
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
      if(parse_constant(false))
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
  
    def parse_constant(signable=true)
      ast_prologue('constant')
      signed = (signable && token_is('-'))
      if(@tokens.first =~ /([0-9]*\.?[0-9]+)/)
        constant = (signed ? '-' : '') + @tokens.shift
	constant.gsub!('_', '')
        return ast(constant)
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
  
  class ASTNode
    attr_accessor :children, :token, :varname, :scratch
    attr_reader :production
  
    def initialize(prod)
      @children = []
      @token = nil
      @production = prod
    end
  
    def add_children(*childs)
      @children.concat childs.clone   
    end
  
    def collapse!
      collapse
      @children.each {|child| child.collapse!}
    end
  
    def child_vars
      @children.map do |child|
        if(child.varname.class == String)
          child.varname
        else
          '$' + child.varname.to_s
        end
      end.join(',')
    end
  
  private
  
    def collapse
      @children.reject! {|child| child.children.empty? && child.token.nil?}
      @children.each_with_index do |child, i|
        if(child.children.length == 1)
          @children[i] = child.children.first
        end
      end
    end
  end
  
  class ThreeTable
    attr_reader :rules, :symboltable
  
    def initialize()
      @symboltable = []
      @rules = []
    end
  
    def addrule(ruleast)
  
      #unwrap rule production
      if(ruleast.children.length == 1)
        ruleast = ruleast.children.first
        ruleast.collapse!
      else
        ruleast.collapse! 
      end
  
      @root = ruleast
      generate(ruleast)
      @rules.push(@symboltable.pop)
    end

    def generate(ast)
      ast.children.each {|child| generate(child) }
      evaluate(ast) 
    end
  
    def evaluate(ast)
      ast.varname = add_symbol(ast.token) if(ast.production == 'constant')
      add_boolean(ast) if (ast.production == 'boolean')
      add_expression(ast) if(ast.production == 'expression')
      add_indicator(ast) if(ast.production == 'indicator') 
      process_arglist(ast) if(ast.production == 'arglist')
      process_exprest(ast) if(ast.production == 'exprest')
      add_ternary(ast) if (ast.production == 'ternary')
      process_clist(ast) if (ast.production == 'clist')
      process_rule(ast) if (ast.production == 'rule')
    end
  
    def process_rule(ast)
      code = '$' + ast.children.first.varname.to_s
      code += " #{ast.token} "
      code += '$' + ast.children.last.varname.to_s
      ast.varname = add_symbol(code)
    end
  
    def process_arglist(ast)
      ast.varname = ast.child_vars 
    end
  
    def process_clist(ast)
      ast.varname = ast.child_vars
    end
  
    def add_boolean(ast)
      code = '$' + ast.children.first.varname.to_s
      code += " #{ast.children[1].token} "
      code += '$' + ast.children[2].varname.to_s
      ast.varname = add_symbol(code)
    end
  
    def add_boolrest(ast)
      ast.varname = ast.children.last.varname
    end
  
    def add_ternary(ast)
      code = '$' + ast.children.first.varname.to_s
      code += " $#{ast.children[1].varname.to_s} "
      code += '$' + ast.children.last.varname.to_s
      ast.varname = add_symbol(code)
    end
  
    def add_expression(ast)
      if(ast.children.length == 1)
        ast.varname = ast.children.first.varname
      else
        op = ast.children.last.children.first.token
        code = "$#{ast.children.first.varname} #{op} $#{ast.children.last.varname}"
        ast.varname = add_symbol(code)
      end
    end
  
    def process_exprest(ast)
      ast.varname = ast.children.last.varname
    end
  
    def add_indicator(ast)
      if(ast.children.length == 1)
        ast.children.first.varname = add_symbol(ast.children.first.token)
        ast.varname = ast.children.first.varname
      else
        code = ast.children.first.token
        childvars = ' ' + ast.children.last.child_vars 
        varname = ast.children.last.varname.to_s
        varname = (varname.start_with?('$') ?  ' ' + varname : " $#{varname}")
        ast.varname = add_symbol(code + varname)
      end
    end
  
    def add_symbol(s)
      if(@symboltable.include?(s))
        @symboltable.index(s)
      else
        @symboltable.push(s)
        @symboltable.length - 1
      end 
    end
  end
end
