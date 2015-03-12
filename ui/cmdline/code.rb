require 'pry'
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
      varname = ' $' + ast.children.last.varname.to_s
      arglist = (childvars.strip.empty? ? varname : childvars)
      ast.varname = add_symbol(code + arglist)
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
