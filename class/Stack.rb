

class Stack
  
  attr_reader :stack, :parent

  def initialize parent
    @stack = []
    @parent = parent
  end
  
  def <<(obj)
    @stack << obj
    obj
  end
  
  def each &blok
    @stack.each &blok
  end
  
  def to_a
    @stack
  end

end # === class Stack
