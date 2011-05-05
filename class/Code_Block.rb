
class Code_Block

  module Module
    
    attr_reader :parent, :code, :lines
    attr_reader :sentences, :nouns, :parsers, :imports

    def initialize parent, code_as_string
      
      case parent
      when Page
        outer = parent.parent && parent.parent.code_block 
      when Sentence, Line
        outer = parent.parent.code_block # code_block of a page
      else
        raise "Unknown class for parent: #{parent.inspect}"
      end # === case
      
      @parent = parent
      @code   = code_as_string
      @lines  = @code
      @sentences = []
      @nouns     = []
      @parsers   = []
      @imports   = []
      
      if outer
        outer_noun =  Noun.new {
          name 'Outer-Block'
          value outer
        }
        @nouns << outer_noun
      end
      
    end
    
    def run
      
      # === Parse code.
      raise "No parses specified." if parsers.empty?
      this = self
      parsers.each { |parser_plugin|
        @lines = parser_plugin.new(this).parse
      }

      # === Execute lines.
      index   = 0
      this    = self
      results = []

      while index < @lines.size

        line  = @lines[index]

        unless line.ignore?

          line.match

          if line.partial_match?
            raise "Did not completely match: #{line.number}: #{line.code}"
          end

          if not line.matched?
            raise "Did not match: #{line.code}"
          end
          
        end

        line.compile

        index += line.skip

      end

      # scope.backtrace << "#{match.sentence.name}: #{match.args.inspect}\n#{line}\n#{sentence.code_block.code}"
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
