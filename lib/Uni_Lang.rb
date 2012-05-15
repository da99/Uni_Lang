require 'Uni_Lang/version'
require 'Split_Lines'
require 'indentation'

class Uni_Lang
  
  attr_accessor :address, :pattern, :tree, :parent, :line, :lineno
  attr_reader   :code

  BASE_TREE = []

  def initialize code
    @address = nil
    @author  = nil
    @pattern = nil
    @code    = standardize(code)
    @tree    = BASE_TREE + []
    @parent  = nil
    @line    = nil
    @lineno  = 0
    yield self if block_given?
  end # === def initialize
  
  def standardize str
    raise ArgumentError, "No tabs allowed." if str["\t"]
    str.reset_indentation
  end

  def run
    this = self
    lines = ( standardize code ).split("\n")
    lines.each_index { |i|
      l = lines[i]
      func = tree.detect { |o| o.respond_to?(:code) && o.match?(l)  }
      if func
        f = func.dup
        f.line = l
        f.lineno = l + 1
        tree << f
      else
        tree << l
      end
      
    }

    tree
  end
  
end # === class Uni_Lang


