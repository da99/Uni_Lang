


class Uni_Lang
  module Core
    
    compile = Event.new { |o|
      o.name = 'compile'
    }

    def compile.action_method
      line = arguments['line']
      name    = line.args['Name'].value
      address = line.args['Address'].value
      line.parent.import address, name
    end
    
    Import_As = Noun.new { |o|
      
      o.name = "import-as"
      o.ancestor << 'Sentence'
      o.importable = true
      o.events << compile 
      
      o.create_property { |prop|
        prop.name = 'pattern'
        prop.value = "Import page as [Word Name]: [Word Address]"
        prop.updateable = false
      }
      
    }
    
    

  end #=== module
end # === class
