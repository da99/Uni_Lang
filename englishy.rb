$KCODE = 'u'
require 'jcode'
require 'yaml'
require 'pp'

# Program (aka applet, doc, document, object, Oberon module, etc.)
#   - author
# Line
#   - address
#   - filename
# Sentence
# Noun
# Parser


PROGRAM  = %~

Superhero is a Noun.
Rocket-Man is a Superhero.
The real-name of Rocket-Man is Bob.
The real-job of Rocket-Man is marriage-counselor.
The real-home of Rocket-Man is Boise,ID.
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


module Sentence
  
  Done_Line = "! Done :)"
  No_Match = Class.new(RuntimeError)
  
  attr_reader :name, :code, :action, :pattern, :pattern_regexp,
    :args, :args_ordered, :replace_pattern, :replace_pattern_regexp, :is_partial

  def initialize name, code, action = :default
    # === PATTERNS
    space = '\\ {0,}'
    word  = "[^\ ]+"
    arg_pattern = %r!\[#{space}([^\ ]+)#{space}([^\ ]+)?#{space}\]!
    split_pattern = %r!\[#{space}[^\ ]+#{space}[^\ ]{0,}#{space}\]!
    
    @action = action
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
  
  def default_action?
    @action === :default
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
    args_with_vals.each { |hash|
      line.args.merge! hash
    }
    
    line
  end

end # === module Sentence

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

module Parser
  
  attr_reader :program
  
  def initialize program
    @program = program
  end

end # === module Parser

class Code_To_Array
  
  include Parser
  
  def parse
    lines = program.lines
    return lines if lines.is_a?(Array)

    program.code.split("\n")
  end

end # === Code_To_Array

class Code_Ignore_Empty_Lines
  
  include Parser

  def parse
    program.lines.each { |line|
      if line.empty?
        line.ignore_this
      end
    }

    program.lines
  end

end # === class Code_Ignore_Empty_Lines

class Code_Array_To_Lines
  
  include Parser

  def parse
    lines = program.lines
    new_lines  = []
    program.lines.each_index { |index|
      line = lines[index]
      new = if line.is_a?(String)
              Line.new index, line, program
            else
              line
            end
      new_lines << new
    }

    new_lines
  end

end # === Code_Array_To_Lines
 
class Code_To_Sub_Program
  
  include Parser
  
  def parse
    program.lines
  end

end # === class Code_To_Sub_Program

class Line 
  
  attr_reader :number, :index, :code, :program, :sentences, :args
  attr_reader :updates, :skip
  
  def initialize raw_index, code, program
    @number    = raw_index + 1
    @index     = raw_index
    @code      = code
    @ignore    = false
    @program   = program
    @sentences = []
    @updates   = []
    @args      = {}
    @skip      = 1
  end

  def match
    return if ignore?
    return if not sentences.empty?

    program.sentences.each { |sentence|
      sentence.new.match_line( index, program )
      break if full_match?
    }
    
    not sentences.empty?
  end

  def compile
    return if ignore?
    sentences.last.compile self
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

class Noun_Create
  
  include Sentence

  def initialize
    super 'noun-create', "[Word] is a [Noun]."
  end

  def compile line
    name     = line.args.index('Word')
    ancestor = line.args.index('Noun')
    
    noun = Noun_By_User.new( name )
    noun.ancestors << ancestor
    line.program << noun
    pp line.args 
    puts ''
  end

end # === class Noun_Create

class Noun_Set_Property
  
  include Sentence

  def initialize
    super 'noun-set-property', "The [Word Prop] of [Noun] is [Word Val]."
  end

  def compile line
    prop = line.args.index('Prop')
    val  = line.args.index('Val')
    noun = line.program.nouns.detect { |n| n.name == line.args.index('Noun') }
    
    noun.set prop, val
    
    puts "#{prop} of #{noun.name} has been set to #{val}"
    puts ''
  end

end # === class Noun_Set_Property

module Noun
  
  attr_reader :name, :propertys, :ancestors
  
  def initialize name, props = {}, actions = []
    @name         = name
    @props        = props
    @actions      = actions
    @ancestors = []
    
    @modules = []
    @icrud = {}
    @propertys = {}
  end

  def data_type?
    false
  end
  
  def valid? str, program
    program.nouns.detect { |noun|
      noun.name == str && noun.ancestors.include?(name)
    }
  end
  
  def has? name
    propertys.has_key?(name)
  end

  def set name, val
    propertys[name] = val
  end

  def get name
    raise "Unknown property: #{name.inspect}" unless has?(name)
    propertys[name]
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

end # === module Noun

class Noun_Number

  include Noun
  
  def data_type?
    true
  end
  
  def valid? str, program
    pos = ( str =~ /\d+(\.\d+)?/ )
    return false if pos == nil
    true
  end

end # === class Noun_Word

class Noun_By_User
  
  include Noun

end # === class Noun_By_User

program = Program.new(PROGRAM) {
  name 'main' 
}

program << Noun_Create
program << Noun_Set_Property

program << Noun_Number

program << Code_To_Array
program << Code_Array_To_Lines
program << Code_Ignore_Empty_Lines
program << Code_To_Sub_Program
 

# require 'rubygems'; require 'ruby-debug'; debugger


program.compile

pp program.nouns

# pp program.lines

# program.run
# 
# puts program.backtrace.to_yaml



__END__






