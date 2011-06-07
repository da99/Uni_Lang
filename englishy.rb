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
  Line 
  Argument

  Noun 

  Noun_Event
  Noun_Event_Describe
  Noun_Event_Run

  Noun_Property
  Noun/Sentence
  
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
#{' ' * 3}
  I am something.
  I am another thing.

Import page as Content-Code: CONTENT
The second-home of Rocket-Man is the real-home of Rocket-Man.
The second-job of Rocket-Man is the real-job of Rocket-Man.



~

BASE_ACTIONS = %~

  Set prop to: this_value.
  if
  unless
    ensure
  +, -, *, /, etc.

~

%~
  
Web-Page is a Noun.
Insert Web-Page into the Importer-Page.

Paragraph is a Noun.

Quick-Paragraph is a Sentence.
A pattern for Quick-Paragraph:
  
  Paragraph:

Quick-Paragraph requires a code block.
Quick-Paragraph does:

  P is a new Paragraph.
  The text for P is the code-block of Calling-Line.
  Insert P into the Web-Page of Calling-Page.






Alias pattern



Paragraph:

  This is a paragraph.
  This continues the paragraph.

Quote:
  
  This is a block quote.
  This is a block quote continued.

Quote:

  This is a quote within a quote.

Paragraph:

  This is a new paragraph.

  This is another paragraph.


~
importables = {
  'CONTENT' => %~
This page is importable.
  ~
}

class Uni_Lang
  module Core
    Core = Code_Block.new { |o|
      o.core = true
    }
  end
end

core = Uni_Lang::Core::Core

# == Parsers
%w{ 
  Code_To_Array
  Code_Array_To_Lines
  Code_Ignore_Empty_Lines
  Code_To_Code_Block
}.each { |name|
  require "class/Parser/#{name}"
  core.plugin eval(name)
}

# == Nouns
%w{ 
  Sentence
}.each { |name|
  require "class/Noun/#{name}"
  core.plugin eval("Uni_Lang::Core::#{name}")
}

# == Sentences
%w{
  Noun_Create
  Noun_Set_Property
  Property_Of_Noun
  Import_As
  Page_Is_Importable
}.each { |name|
  require "class/Sentence/#{name}"
  core.plugin eval("Uni_Lang::Core::#{name}")
}

program = Page.new { |o|
  
  o.file_address = __FILE__
  o.name         = 'main'
  o.code         = PROGRAM
  o.parent       = core
    
}

puts PROGRAM

puts ''
puts ''

program.code_block.find_file = lambda { |address, code_block|
  importables[address]
}


program.code_block.run

pp program.code_block.nouns.map(&:inspect_informally)

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

TODO:
  * property of Noun => (partial sentence)
  * Sentence definition.
  * Passing outer, local, etc. scopes.
  * HTML/CSS/JS converters.


