

class Noun_Set_Property
  
  include Sentence::Module

  def initialize
    super 'noun-set-property', "The [Word Prop] of [Noun] is [Word Val]."
  end

  def compile line
    prop      = line.args['Prop'].value
    val       = line.args['Val'].value
    noun_name = line.args['Noun'].value
    noun      = line.parent.detect_noun_named( noun_name )
    
		noun.create_property { |o|
			o.name       = prop
			o.value      = val
			o.updateable = false
		}
  end

end # === class Noun_Set_Property
