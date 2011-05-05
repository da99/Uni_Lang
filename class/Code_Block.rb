
class Code_Block

  module Module
    
    attr_reader :parent, :code
    attr_reader :sentences, :nouns, :parsers, :imports

    def initialize parent, code_as_string

      @parent = parent
      @code   = code_as_string
      
      outer = parent.code_block || self.class.new
      outer_noun = Noun.new {
        name 'Outer-Block'
        value outer
      }
      @sentences = []
      @nouns     = [ outer_noun ]
      @parsers   = []
      @imports   = []
      
      case parent
      when Page
        @env = Env.new
      when Sentence
        @env = Env.new
      when Line
        @env = Env.new
      else
        raise "Unknown class for parent: #{parent.inspect}"
      end # === case
      
    end
    
    def execute context
      raise "not implemented"
    end
    
    def << obj

      found = [ Noun, Sentence, Parser ].detect { |klass|
        if klass == obj || 
          obj.class.included_modules.include?(klass.const_get(:Module)) ||
          ( obj.respond_to?(:included_modules) && obj.included_modules.include?(klass.const_get(:Module)) )
          klass
        else
          nil
        end
      }

      raise "Unknown class for: #{obj.inspect}" unless found

      stack_name = found.to_s.downcase + 's'
      send( stack_name ).send :<<, obj

      obj

    end
    alias_method :plugin, :<<
    
  end # === module
  
  include Module

end # === class 
