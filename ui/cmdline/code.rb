
class ASTNode
  attr_accessor :children, :token

  def initialize()
    @children = []
    @token = nil
  end

  def add_children(*childs)
    @children.concat childs.clone   
  end

  def collapse!
    collapse
    @children.each {|child| child.collapse!}
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
  def initialize(root)
    root.collapse!
  end
end
