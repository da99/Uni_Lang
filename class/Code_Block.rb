
class Code_Block

  module Module
    
    def initialize parent
      
      case parent
        
      when Document
        @code = parent.code
        
      when Sentence
        @code = parent.code
        
      else
        raise "Unknown class for parent: #{parent.inspect}"
        
      end # === case
      
    end
    
    def execute context
      raise "implemented"
    end
    
  end # === module

end # === class 
