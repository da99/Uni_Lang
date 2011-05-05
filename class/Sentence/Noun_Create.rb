

class Noun_Create
  
  include Sentence::Module

  def initialize
    super 'noun-create', "[Word] is a [Noun]."
  end

  def compile line
    name     = line.args.index('Word')
    ancestor = line.args.index('Noun')
    
    noun = Noun_By_User.new( name )
    noun.ancestors << ancestor
    line.code_block << noun
    pp line.args 
    puts ''
  end

end # === class Noun_Create
