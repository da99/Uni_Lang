
class Uni_Lang
  module Core
    
    Page_Is_Importable = Noun.new { |o|

      o.name = 'page-is-importable'
      o.ancestor << 'Sentence'
      o.importable = true
 
      o.create_property { |prop|
        prop.name = 'pattern'
        prop.value = "This page is importable."
        prop.updateable = false
      }
      
      o.events << Event.new { |e|
        e.name = 'compile'
        e.action_proc = lambda { |ev|
          line = ev.arguments['line']
          page = line.parent.parent

          raise "This line can only be used at top of page." unless page.is_a?(Page)
          page.importable = true
        }
      }
      
    }

  end # === core
end # === class


