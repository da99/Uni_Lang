

class Noun_Set_Property
  
  include Sentence

  def initialize
    super 'noun-set-property', "The [Word Prop] of [Noun] is [Word Val]."
  end

  def compile line
    prop = line.args.index('Prop')
    val  = line.args.index('Val')
    noun = line.program.nouns.detect { |n| n.name == line.args.index('Noun') }
    
    noun.set prop, val
    
    puts "#{prop} of #{noun.name} has been set to #{val}"
    puts ''
  end

end # === class Noun_Set_Property
