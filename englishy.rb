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
prog = Uni_Lang::Core::Code_Block.create('my program') { |n|

  n.immutable_property('code', PROGRAM)
  n.immutable_property('file_address', __FILE__)
  
}

prog.run_event('run')


pp prog.read_property('nouns').map(&:inspect_informally)


__END__

* No creation of objects except by self.
  Namespacing which allows scalable dev.

* Special require for non-self requires.
  Require url() for Importer.
  Alias-Name as url() found in Importer.

* Exportable sentences and client-sentences.
  Visible: Importer, Importee.

* This-Server-Page, The-Client.
  Visible on all code blocks.

* Require takes in a block.
  Author has to specify actions for imported code.
  Imported code does not assume a certain object is created.
  
* Functionality is added through events + exported sentences.
  Bugs are avoided through namespacing + Noun Visible=False.

* Nouns: Maps + Events = All features you could ever want - Factor 

* Simple Ruby Objects for messages (aka events.)  
  Hash used to store state and functionality.

* Validation and Permissions ENTIRELY done by the site.
  No reason for user to set up their own validation/permission
  system.
    
* Authorization: Permissions manage by site.
  Authentication: Standard practices.
  EVAL: No eval possible. Everything is a string that is treated as a key/id.
  Data sent to criminal: data can't be sent outside of user permission system.
    JS AJAX: all calls are sent within site url and user urls. No custom urls allowed.
    No HTML/CSS/JS allowed.
  JS in CSS: CSS is scrubbed and validated. No JS allowed.
  Rating system for code.
    Flagged code is de-activated.
    User hierarchy for marking code as insecure or criminal.
  Security is handled at site level (aka Uni Lang).
    Must assume no one listens and does the right thing.
    Tests and certification is not enough.
  Some parts of the site are not editable: 
    Permission granting system to code and urls.
    Records involving permission code, urls, etc.
    
    


Record is from the Database:
  
  The id is: 42.
  The table-name is: CDs.
  Grab fields: title, intro.

The-Page is a Client-Page.

Viewable to all code blocks:
  * Record
  * The-Page
  * Client

On end of this code block:

  Respond to Client with The-Page.
  
The title of The-Page is:

  title of Record.

In The-Page, Intro is a Paragraph:

  intro of Record.

Create Random on data-map of The-Page:
  
  Hans Hoppe is fun.
  
On mouse click on Intro:

  Alert: title of The-Page.
  Alert: Random of data-map of The-Page.
  Update border-right of Intro of The-Page to: 2px solid red.
  

  
Uni_Lang for JavaScript
- Definitions on top only
- KV Map for server/client communication.
- JS simple objects for now only.
  UL obj sys. on server only. Can be used for
  validation.
- basic ops for server apply to client: adding, comparison , setting
- noun references: server to client
- Nouns/Sentences have different representations:

  HTML
  JavaScript
  
  Example: 
    Sun-creation is a Paragraph.
    On click of Sun-creation:
      Alert: word-count of Sun-creation.
      
    ==>
  
    Define client property, word-count, on Noun as function:
      Text is the text of Noun.
      Words is the split of text on empty space.
      Return count of Words.
      
    Define client sentence:
      Alert: {val}
      Send('alert', val);

    n = Paragraph.create('Sun-creation').
    n.on_event('js on-click') { |e|
      Client.alert(n.read_property('word-count'))
    }
    
      ==>
      <p id="Sun-creation">Some text.</p>
      <script>
        // Require jquery.
        $('Sun-creation').onclick(function(){
          window.alert( $('Sun-creation').property('inner-text').to_s.split(' ').size()  );
        });
      </script>


Uni_Lang::Core::Core.event_as_property('find_file') { |e|
  importables[e.args.address]
}

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
  
  
