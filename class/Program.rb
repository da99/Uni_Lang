

class Program
  
  GET_VAL = :_get_

  class << self
    
    def parse str_or_array
      case str_or_array
      when Array
        str_or_array
      when String
        str = str_or_array
        str.split("\n").reject { |sub| sub.strip.empty? }
      else
        raise "Unknown class: #{str_or_array.inspect}"
      end
    end
    
  end # === class << self
  
  attr_reader :code, :lines, :position, :backtrace
  attr_reader :nouns, :sentences, :parsers, :imports
  
  def initialize str, &blok
    @code = str
    @lines                = @code
    @backtrace            = []

    @noun_scope           = []
    @sentence_scope       = []

    @parent               = nil # like a code block
    @importer             = nil # like python's 'import'

    @starting_line_number = 0
    @current_line_number  = 0

    @name                 = "_unknown_"
    @directions           = nil
    @nouns                = []
    @sentences            = []
    @parsers              = []
    @imports              = []

    @code_filters         = []
    @indent               = -1
    
    instance_eval( &blok ) if block_given?

  end

  def file_address val = nil
    return @file_address unless val
    @file_address = val
  end

  def name val = nil
    return @name unless val
    @name = val
  end
  
  def import new_name, new_file_address, new_program
    this = self
    
    new_import = Program.new(new_program) {
      name new_name
      file_address new_file_address
      importer this
    }
    
    @sentences << new_import
    @imports << new_import
  end

  def importer val = nil
    return @importer unless val
    @importer = val
  end

  def parent val = nil
    return @parent unless val
    @parent = val
  end

  def parse
    raise "No parses specified." if parsers.empty?
    this = self
    parsers.each { |parser_plugin|
      @lines = parser_plugin.new(this).parse
    }
  end

  def compile
    parse
    
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
    
    # scope.backtrace << "#{match.sentence.name}: #{match.args.inspect}\n#{line}\n#{sentence.code}"
  end

  def << obj
   
    if obj.respond_to?(:ancestors)
      target = ( [ Noun, Sentence, Parser ] & obj.ancestors ).first
    end
    
    if not target 
      target = obj
    else
      target = target.to_s
    end
    
    case target
    when Noun.to_s, Noun
      nouns.unshift obj
    when Sentence.to_s, Sentence
      sentences << obj
    when Parser.to_s, Parser
      parsers << obj
    else
      raise "Unknown Plugin Type: #{obj.inspect}"
    end

  end

  def run raw_program
    @indent = @indent + 1
    program = case program
              when String
                Program.new(program)
              when Program
                raw_program
              else
                raise "Unknown program: #{raw_program.inspect}"
              end
    @indent = @indent - 1
  end
  
end # === class
