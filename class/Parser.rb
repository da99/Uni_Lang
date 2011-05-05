
class Parser

  module Module
    
    attr_reader :code_block
    
    def initialize code_block
      @code_block = code_block
    end

  end # === module 
  
  include Module

end # === class 
