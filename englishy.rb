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
  Sentence 
  Noun 
  Line 
  
}.each { |name|
  require "class/#{name}"
}

# == Parser Plugins
%w{ 

  Code_Array_To_Lines
  Code_Ignore_Empty_Lines
  Code_To_Array
  Code_To_Code_Block

}.each { |name|
  require "class/Parser/#{name}"
}

# == Sentence Plugins

%w{

  Noun_Create
  Noun_Set_Property

}.each { |name|
  require "class/Sentence/#{name}"
}


# == Noun Plugins
%w{ 

  Noun_Number
  Noun_By_User

}.each { |name|
  require "class/Noun/#{name}"
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
}

program << Noun_Create
program << Noun_Set_Property

program << Noun_Number

program << Code_To_Array
program << Code_Array_To_Lines
program << Code_Ignore_Empty_Lines
program << Code_To_Code_Block
 

# require 'rubygems'; require 'ruby-debug'; debugger



puts PROGRAM

puts ''
puts ''

program.compile
pp program.nouns

# pp program.lines

# program.run
# 
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




