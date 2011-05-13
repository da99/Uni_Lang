

class Noun_Create
  
  include Sentence::Module

  def initialize
    super 'noun-create', "[Word] is a [Noun]."
  end

  def compile line
    name     = line.args.index('Word')
    ancestor = line.args.index('Noun')
		parent     = line.code_block.parent
		importable = parent.is_a?(Page) && parent.importable
		
		line.code_block.create_noun { |o|
			o.name = name
			o.ancestors << ancestor
			o.importable = importable
		}
  end

end # === class Noun_Create
