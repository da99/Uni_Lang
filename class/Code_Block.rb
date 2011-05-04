
class Code_Block

  module Module
    
    attr_reader :env

    def initialize parent
      
      case parent
        
      when Page
        @code = parent.code
        
      when Sentence
        @code = parent.code
        
      else
        raise "Unknown class for parent: #{parent.inspect}"
        
      end # === case
      
      @env = Env.new(parent.env)
      
    end
    
    def execute context
      raise "not implemented"
    end
    
  end # === module
  
  include Module

end # === class 
