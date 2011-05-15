
class Code_Block

  module Module
    
    attr_reader :sentences, :nouns, :parsers, :imports
		attr_writer :find_file
    attr_accessor :parent, :code, :lines, :core

    protected :lines=
      
    def initialize
      
      # case parent
      # when Page
      #   outer = parent.parent && parent.code_block 
      # when Sentence, Line
      #   outer = parent.parent.code_block # code_block of a page
      # else
      #   raise "Unknown class for parent: #{parent.inspect}"
      # end # === case
      
      @parent = nil
      @code   = nil
      @lines  = nil
      @core   = false
      @sentences = []
      @nouns     = []
      @parsers   = []
      @imports   = []
      
      yield(self)
      if core && !code
        @code = ''
      end
      @lines = @code
      
      if !core && !code
        raise "Code is required."
      end

      if parent
        outer_noun =  Noun.new { |o|
          o.name  = 'Outer-Block'
          o.create_property { |prop|
            prop.name  = 'value'
            prop.value = parent
          }
        }
        @nouns << outer_noun
      end
      
      if !core && core_code_block
        @sentences << core_code_block
        @nouns << core_code_block
        @parsers << core_code_block
      end
      end
      
    end
  
    def detect_noun &blok
      found = nil
      nouns.each { |unknown|
        
        if unknown.respond_to?(:detect_noun)
          unknown.detect_noun(&blok)
        else
          found = unknown if blok.call(unknown)
        end
        
        break if found
      }
      
      found
    end

    def match_line_to_sentences line
      
      new_sentences = [] 
			sentences.each { |scope|
        
        new_sentences << if scope.respond_to?(:new)
          
          sentence = scope.new
          sentence.match_line( line )
          sentence if sentence.matched
            
        elsif scope.respond_to?(:match_line_to_sentences)
          
          scope.match_line_to_sentences line
          
        else
          
          raise "Unknown sentence class: #{scope.inspect}"
          
        end
        
        if line.full_match?
          break
        end
        
      }
      
      new_sentences.flatten.compact
      
    end
    
    def parse target = :none
      
      if target === :none
        @lines = @code
        return( parse( self ) ) 
      end
        
      raise "No parsers specified." if parsers.empty?
      
      parsers.each { |plugin|
        
        target.lines = if plugin.respond_to?(:parse)
                         plugin.parse( target )
                       elsif plugin.respond_to?(:code_block)
                         plugin.code_block.parse( target )
                       else
                         raise "Unknown class for parser plugin: #{plugin.inspect}"
                       end

      }
      
      target.lines
    end

    def run
      
      # === Parse code.
      parse

      # === Execute lines.
      index   = 0
      this    = self
      results = []

      while index < @lines.size

        line  = @lines[index]

        unless line.ignore

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
    
    def create_noun &blok
      noun = Noun.new( &blok )
      self.plugin noun
    end

    def import file_address, name_alias
      find_file = self.find_file
      raise "Find file function not found." unless find_file
      content     = find_file.call file_address, self
      raise "File not found: #{file_address} (#{name_alias})" unless content
      this        = self
      
      new_page = Page.new { |o|
        
        o.file_address = file_address
        o.name         = name_alias
        o.parent       = this
        o.code         = content
        
      }
      
      new_page.code_block.run
      raise "Not importable: #{file_address}" unless new_page.importable?
      
      sentences << new_page
      nouns << new_page
      imports << new_page
      parsers << new_page
    end

    def find_file
      return @find_file if @find_file
      parent = self.parent
      
      while parent 
        if parent.is_a?( Code_Block ) && parent.find_file
          find_file = parent.find_file
          break
        end
        parent = parent.parent
      end
      
      find_file
    end

		# def top_env
		# 	current = self
      begin
		# 		
		# 		meth = [:parent, :code_block].detect { |meth_name|
		# 			current.respond_to? meth_name
		# 		}
		# 		
		# 		current.send meth
		# 	end	while next_parent.nil?
		# end
    
    def core_code_block
      return nil if core
      raise "No parent or core code block found." unless self.parent

      is_core = lambda { |unknown|
        unknown.is_a?(Code_Block) && 
          unknown.core
      }
      
      target = self
      while not is_core.call(target)
        target = target.parent
      end
      
      target
    end
    
    def inspect_informally
      "Code_Block - core: #{core.inspect}"
    end

  end # === module
  
  include Module

end # === class 
