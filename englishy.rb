$KCODE = 'u'
require 'jcode'
require 'yaml'
require 'pp'

# Code Block (aka page, applet, doc, document, object, Oberon module, etc.)
#   
# Noun
#   - Sentence
#   - Code Block
#     - file address
#     - line number
#   - Code Block Import
#     - value: Code Block
#   - Code Block Alias
#     - value: Code Block
# Line
#   - address
#   - filename
#   
# Modules: 
#   Sentence
#   Noun
#   Parser

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



puts PROGRAM
puts ''
puts ''

require 'class/Noun/Core'
Uni_Lang::Core::Core.event_as_property('find_file') { |e|
  importables[e.args.address]
}

prog = Noun.new('my program', 'Code Block') { |n|

  n.immutable_property('code', PROGRAM)
  n.immutable_property('file_address', __FILE__)
  
}

prog.run_event('run')


pp prog.read_property('nouns').map(&:inspect_informally)


__END__

------------------------------------------------------------------

  forward an event to value of Noun
    run_event('compile line') -> noun.value.run_event...
   ----------------   
  n.run_event('match line to sentence') { |e|
    e.args['line']         = line
    e.args['file_address'] = line
  }

   ----------------   
program = Page.new { |o|
  
  o.file_address = __FILE__
  o.name         = 'main'
  o.code         = PROGRAM
  o.parent       = core
    
}

program.code_block.find_file = lambda { |address, code_block|
  importables[address]
}
program.code_block.run
pp program.code_block.nouns.map(&:inspect_informally)
puts program.backtrace.to_yaml


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
