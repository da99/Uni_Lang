$KCODE = 'u'
require 'jcode'

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


class Document
end # === class

class Noun
  attr_reader name
  def initialize name, props = {}, actions = []
    @name         = name
    @props        = props
    @actions      = actions
    @noun_classes = []
  end
end # === class

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
      raise No_Match, "#{@line} |->| #{sentence.text}"
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

class Sentence
  
  attr_reader :name, :text, :pattern, :args, :args_ordered, :replace_pattern

  def initialize name, text
    # === PATTERNS
    space = '\\ {0,}'
    word  = "[^\ ]+"
    arg_pattern = %r!\[#{space}([^\ ]+)#{space}([^\ ]+)?#{space}\]!
    split_pattern = %r!\[#{space}[^\ ]+#{space}[^\ ]{0,}#{space}\]!
    
    @name = name
    @text = text
    
    @arg_wrappers = text.
                split(split_pattern).
                map { |piece| Regexp.escape(piece) }
                
    @pattern = @arg_wrappers.
                join('(' + word + ')') 
    
    @replace_pattern = @arg_wrappers.join(word)
    
    begin
      arg_pairs = text.scan(arg_pattern) # => [ [ 'Noun', nil ] ,  [ 'Word', 'URL' ]  ]
      args    = {}
      ordered = []

      arg_pairs.each { |pair|
        type = pair[0]
        label = pair[1] || type

        if args.has_key?(label)
          raise Author_Error, %~"#{label}" already used in: #{text}.~ 
        end
        args[label] = type
        ordered << [label, type]
      }

      @args = args
      @args_ordered = ordered
    end
  end

end # === class

class Verb
end # === class

class Stack
  
  attr_reader :name, :stack

  def initialize name
    @name = name
    @stack = []
  end
  
  def <<(obj)
    @stack << obj
  end
  
  def each &blok
    @stack.each &blok
  end

end # === class

class Uni_Lang
  
  class << self
    
    def parse str
      str.split("\n").reject { |sub| sub.strip.empty? }
    end
    
    def parse_sentence str
      str.split
    end

  end # === class << self
  
  attr_reader :original, :final, :array, :position
  
  def initialize str, sentences, nouns
    @lines    = self.class.parse(str)
    @original = str
    @sentences = sentences
    @nouns    = nouns
  end
  
  def parse
    @lines.each { |line|
      finished = false
      original_line = line
      Sentences.each { |sentence|
        
        begin
          match = Sentence_Match.new( line, sentence )
          
          Backtrace << "#{match.sentence.name}: #{match.args.inspect}\n#{line}\n#{sentence.text}"

          if match.all?
            finished = true
            break
          end
          line = match.updated_line
        rescue Sentence_Match::No_Match
        end
        
      }
      
      if not finished
        if original_line == line
          raise "Did not match: #{original_line}"
        else
          raise "Did not completely match: #{original_line}"
        end
      end
    }
  end

end # === class

Backtrace = []
Sentences = Stack.new('Sentences')
Sentences << Sentence.new('new-noun', "[Word] is a [Noun].")
Sentences << Sentence.new('set-property', "The [Word Prop] of [Noun] is [Word Val].")

Nouns = Stack.new('Nouns')
Nouns << Noun.new('Noun',   { :data_type=>'true'}, [:exist])
Nouns << Noun.new('Word',   { :data_type=>'true'}, [:anything])
Nouns << Noun.new('Number', { :data_type=>'true'}, [:number])

 
require 'yaml'
puts Sentences.to_yaml

parser = Uni_Lang.new( PROGRAM, Sentences, Nouns )
parser.parse

puts Backtrace.to_yaml



__END__


module Englishly_Syntax
  
  def closed_word?
    closed_something? 'word'
  end
  
  def closed_noun?
    closed_something? 'noun'
  end

  def closed_something? wrd
    self.upcase == "[#{wrd.upcase}]"
  end

end # === module
Nouns << Noun.new('Superhero', :"real-name" => nil, :"real-job" => nil)


Word_Types = Stack.new('Word_Types')
Word_Types << Word_Type.new('Noun', :exist)
Word_Types << Word_Type.new('Word', :anything)
Word_Types << Word_Type.new('Number', :number)






