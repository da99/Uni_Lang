
class Uni_Lang
  module Core
    
    Noun_Set_Property = Noun.new { |o|
      
      o.name = 'noun-set-property'
      o.ancestor << 'Sentence'
      o.importable = true
      
      o.create_property { |prop|
        prop.name = 'pattern'
        prop.value = "The [Word Prop] of [Noun] is [Word Val]."
        prop.updateable = false
      }
      
      o.on 'compile' do |ev|
        line      = ev.arguments['line']
        prop      = line.args['Prop'].value
        val       = line.args['Val'].value
        noun_name = line.args['Noun'].value
        noun      = line.parent.detect_noun_named( noun_name )

        if !noun
          raise "Noun does not exist: #{noun_name}"
        end

        noun.create_property { |o|
          o.name       = prop
          o.value      = val
          o.updateable = false
        }
      end

    }

  end # === core
end # === class

