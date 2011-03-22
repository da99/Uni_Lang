$KCODE = 'u'
require 'jcode'
require 'yaml'
require 'pp'

# Doc (aka applet, object, Oberon module, etc.)
#   - Nouns
#   - Verbs
#   - Documents
#   - Meta
#     - address
#     - filename
#     - author
#
# Noun
# Verb
#

PROGRAM  = %~

Superhero is a Noun.
Rocket-Man is a Superhero.
The real-name of Rocket-Man is Bob.
The real-job of Rocket-Man is marriage-counselor.

~

BASE_ACTIONS = %~

  Set prop to: this_value.
  if
  unless
    ensure
  +, -, *, /, etc.
~

module Askable
  
  def askable
    @askable ||= {}
  end

  def set name, val
    raise "Already set: #{name.inspect}" if askable.has_key?(name)
    update_or_set name, val
  end

  def ask name
    raise "Key not found: #{name.inspect}" if not askable.has_key?(name)
    askable[name]  
  end

  def get name
    ask name
  end

  def update name, val
    ask name
    update_or_set name, val
  end

  def update_or_set name, val
    askable[name] = val
  end

end # === module Askable


class Document
end # === class

class Noun
  
  attr_reader name
  
  def initialize name, props = {}, actions = []
    @name         = name
    @props        = props
    @actions      = actions
    @noun_classes = []
    
    @modules = []
    @icrud = {}
  end

  def set_prop name, val
  end

  def get_prop name, val
  end

  def on_initialize
  end

  def on_create
  end

  def on_read
  end

  def on_update
  end

  def on_delete
  end

  def on_undelete
  end

end # === class

class Sentence
  
  Done_Line = "! Done :)"
  No_Match = Class.new(RuntimeError)
  
  attr_reader :name, :code, :pattern, :pattern_regexp,
    :args, :args_ordered, :replace_pattern, :replace_pattern_regexp, :is_partial

  def initialize name, code
    # === PATTERNS
    space = '\\ {0,}'
    word  = "[^\ ]+"
    arg_pattern = %r!\[#{space}([^\ ]+)#{space}([^\ ]+)?#{space}\]!
    split_pattern = %r!\[#{space}[^\ ]+#{space}[^\ ]{0,}#{space}\]!
    
    @is_partial = false
    @name = name
    @code = code
    
    @arg_wrappers = code.
                split(split_pattern).
                map { |piece| Regexp.escape(piece) }
                
    @pattern = @arg_wrappers.
                join('(' + word + ')') 
    @pattern_regexp = Regexp.new(@pattern)
    
    @replace_pattern = @arg_wrappers.join(word)
    @replace_pattern_regexp = Regexp.new(@replace_pattern)
    
    begin
      arg_pairs = code.scan(arg_pattern) # => [ [ 'Noun', nil ] ,  [ 'Word', 'URL' ]  ]
      args    = {}
      ordered = []

      arg_pairs.each { |pair|
        type = pair[0]
        label = pair[1] || type

        if args.has_key?(label)
          raise Author_Error, %~"#{label}" already used in: #{code}.~ 
        end
        args[label] = type
        ordered << [label, type]
      }

      @args = args
      @args_ordered = ordered
    end
  end
  
  def match_line index, program
    
    line = program.lines[index]
    
    args = line.code.scan(pattern_regexp)
    
    return line if args.empty?
    #   raise No_Match, "#{line.code} |->| #{code}"
    # end
    
    args_with_vals = []

    args.each { |each_match|
      pairs = each_match.zip(args_ordered)
      args_with_vals << pairs.inject({}) { |memo, pair|
        memo[pair[0]] = pair[1][0]
        memo
      }
    }

    line.sentences << self
    line.updates << line.code.gsub(replace_pattern_regexp, Done_Line)
    line.args << args_with_vals
    
    line
  end

end # === class

class Stack
  
  attr_reader :stack, :parent

  def initialize parent
    @stack = []
    @parent = parent
  end
  
  def <<(obj)
    @stack << obj
    obj
  end
  
  def each &blok
    @stack.each &blok
  end
  
  def to_a
    @stack
  end

end # === class Stack

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
      @lines = parser_plugin.parse(this)
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
        @sentences.each { |sentence|
          sentence.match_line( index, this )
          break if line.full_match?
        }
        
        if line.partial_match?
          raise "Did not completely match: #{line.number}: #{line.code}"
        end

        if not line.matched?
          raise "Did not match: #{line.code}"
        end
      end
        
      index += line.skip
      
    end
    
    # scope.backtrace << "#{match.sentence.name}: #{match.args.inspect}\n#{line}\n#{sentence.code}"
  end

  def << obj
    
    case obj
    when Sentence
      sentences << obj
    when Noun
      nouns << obj
    else
      if obj.respond_to?(:plugin_type)
        case obj.plugin_type
        when :parser
          parsers << obj
        else
          raise "Unknown Plugin Type: #{obj.inspect}"
        end
      else
        raise "Unknown object: #{obj.inspect}"
      end
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

class Code_To_Array
  
  class << self

    def plugin_type
      :parser
    end

    def parse program
      lines = program.lines
      return lines if lines.is_a?(Array)
      
      program.code.split("\n")
    end
    
  end # === class << self

end # === Code_To_Array

class Code_Ignore_Empty_Lines
  
  class << self
    
    def plugin_type
      :parser
    end

    def parse program
      program.lines.each { |line|
        if line.empty?
          line.ignore_this
        end
      }
      
      program.lines
    end

  end # === class << self

end # === class Code_Ignore_Empty_Lines

class Code_Array_To_Lines
  
  class << self
    
    def plugin_type
      :parser
    end

    def parse program
      lines = program.lines
      new_lines  = []
      program.lines.each_index { |index|
        line = lines[index]
        new = if line.is_a?(String)
                Line.new index, line
              else
                line
              end
        new_lines << new
      }
      
      new_lines
    end

  end # === class << self

end # === Code_Array_To_Lines
 
class Code_To_Sub_Program
  
  class << self
    
    def plugin_type
      :parser
    end
    
    def parse program
      program.lines
    end

  end # === class << self

end # === class Code_To_Sub_Program

class Line 
  
  attr_reader :number, :code, :sentences, :args
  attr_reader :updates, :skip
  
  def initialize raw_index, code
    @number    = raw_index + 1
    @index     = raw_index
    @code      = code
    @ignore    = false
    @sentences = []
    @updates   = []
    @args      = []
    @skip      = 1
  end

  def empty?
    code.strip.empty?
  end

  def ignore?
    @ignore
  end
  
  def ignore_this
    @ignore = true
  end
  
  def matched?
    not updates.empty?
  end

  def full_match?
    matched? && updates.last == Sentence::Done_Line
  end
  
  def partial_match?
    matched? && !full_match?
  end
  
  def skip_next num
    @skip += num
  end

end # === class Line


program = Program.new(PROGRAM) {
  name 'main' 
}

program << Sentence.new('new-noun', "[Word] is a [Noun].")
program << Sentence.new('set-property', "The [Word Prop] of [Noun] is [Word Val].")

program << Noun.new('Noun',   { :data_type=>'true'}, [:exist])
program << Noun.new('Word',   { :data_type=>'true'}, [:anything])
program << Noun.new('Number', { :data_type=>'true'}, [:number])

program << Code_To_Array
program << Code_Array_To_Lines
program << Code_Ignore_Empty_Lines
program << Code_To_Sub_Program
 

# require 'rubygems'; require 'ruby-debug'; debugger


program.compile

pp program.lines

# program.run
# 
# puts program.backtrace.to_yaml



__END__


Nouns << Noun.new('Superhero', :"real-name" => nil, :"real-job" => nil)



class Sentence_Match
  
  No_Match = Class.new(RuntimeError)
  Done_Line = "! Done :)"
  attr_reader :line, :sentence, :args

  def initialize line, sentence
    @line         = line
    @sentence     = sentence
    @updated_line = nil
    
    args = @line.scan(Regexp.new(sentence.pattern))

    if args.empty?
      raise No_Match, "#{@line} |->| #{sentence.code}"
    end
    
    args_with_vals = []

    args.each { |each_match|
      pairs = each_match.zip(sentence.args_ordered)
      args_with_vals << pairs.inject({}) { |memo, pair|
        memo[pair[0]] = pair[1][0]
        memo
      }
    }

    @updated_line = @line.gsub(Regexp.new(sentence.replace_pattern), Done_Line)
    @args = args_with_vals
  end
  
  def updated_line
    raise "No updated line set." unless @updated_line
    @updated_line
  end
  
  def all?
    @updated_line == Done_Line
  end

end # === class


class Stack_Loop_Result
  
  include Askable
  
  attr_reader :core, :ancestor

  def initialize core, ancestor
    @core = core
    @ancestor = ancestor
  end
  
end # === class Stack_Loop_Result




class Stack_Loop
  
  attr_reader :results, :stack

  def initialize stack
    @stack   = []
    @copy    = @stack.clone
    @results = Stack.new
  end

  def start
    this = self
    @copy.each { |item|
      yield Stack_Loop_Item.new(item)
    }
  end

end # === class Stack_Loop

class Stack_Loop_Step
  
  attr_reader :core, :stack_loop, :index

  def initialize core, stack_loop, index
    @core       = core
    @stack_loop = origin
    @index      = index
  end
  
  def << val
    stack_loop.results Stack_Loop_Step.new( val, self )
    val
  end

end # === class Stack_Loop_Step

class Stack_Loop_Result
  
  attr_reader :core, :parent

  def initialize core, parent
    @core = core
    @parent = parent
  end

end # === class Stack_Loop_Result


