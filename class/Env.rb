
class Env 
  
  module Module

    attr_reader :sentences, :nouns, :parsers, :imports
    
    def initialize outer = nil
      outer ||= self.class.new
      outer_noun = Noun.new {
        name 'Outer-Environment'
        value outer
      }
      @sentences = []
      @nouns     = [ outer_noun ]
      @parsers   = []
      @imports   = []
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
