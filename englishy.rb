$KCODE = 'u'
require 'jcode'
require 'yaml'
require 'pp'

# Page (aka applet, doc, document, object, Oberon module, etc.)
#   - author
# Line
#   - address
#   - filename
# Modules: 
#   Sentence
#   Noun
#   Parser

# == Classes 
%w{ 
  
  Page 
  Parser 
  Code_Block
  Env
  Sentence 
  Noun 
  Line 
  
}.each { |name|
  require "class/#{name}"
}



# ========================================================

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

program = Page.new(PROGRAM) {
  name 'main' 
  
  # == Sentences
  %w{

    Noun_Create
    Noun_Set_Property

  }.each { |name|
    require "class/Sentence/#{name}"
    code_block.plugin eval(name)
  }

  # == Parsers
  %w{ 

    Code_Array_To_Lines
    Code_Ignore_Empty_Lines
    Code_To_Array
    Code_To_Code_Block

  }.each { |name|
    require "class/Parser/#{name}"
    code_block.plugin eval(name)
  }
  
  # == Nouns
    # Noun_By_User
  %w{ 

    Noun_Number

  }.each { |name|
    require "class/Noun/#{name}"
    code_block.plugin eval(name)
  }

    
}

 
# require 'rubygems'; require 'ruby-debug'; debugger


puts PROGRAM

puts ''
puts ''

program.run
pp program.nouns

# puts program.backtrace.to_yaml



__END__




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




