

class Noun_Set_Property
  
  include Sentence::Module

  def initialize
    super 'noun-set-property', "The [Word Prop] of [Noun] is [Word Val]."
  end

  def compile line
    prop = line.args.index('Prop')
    val  = line.args.index('Val')
    noun = line.parent.detect_noun { |n| n.name == line.args.index('Noun') }
    
		noun.create_property { |o|
			o.name       = prop
			o.value      = val
			o.updateable = false
		}
  end

end # === class Noun_Set_Property
