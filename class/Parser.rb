
class Parser

  module Module
    
    attr_reader :program
    
    def initialize program
      @program = program
    end

  end # === module 
  
  include Module

end # === class 
