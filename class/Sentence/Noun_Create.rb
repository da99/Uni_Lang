

class Uni_Lang
  module Core
    
    compile = Event.new { |o|
      o.name = 'compile'
    }
    
    def compile.action_method
      line = arguments['line']
      name     = line.args['Word'].value
      ancestor = line.args['Noun'].value
      parent     = line.parent.parent
      importable = parent.is_a?(Page) && parent.importable

      line.parent.create_noun { |o|
        o.name = name
        o.ancestors << ancestor
        o.importable = importable
      }
    end
    
    Noun_Create = Noun.new { |o|
      
      o.name = 'noun-create'
      o.ancestor << 'Sentence'
      o.importable = true
      o.events << compile
      o.create_property { |prop|
        prop.name = 'pattern'
        prop.value = "[Word] is a [Noun]."
        prop.updateable = false
      }
      
    }
    
  end # === Core
end # === class

