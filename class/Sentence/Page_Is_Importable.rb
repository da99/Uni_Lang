
class Uni_Lang
  module Core
    
    Page_Is_Importable = Noun.new { |o|

      o.parent = ::Uni_Lang::Core::Core
      o.name = 'page-is-importable'
      o.ancestors << 'Sentence'
      o.importable = true
 
      o.create_property { |prop|
        prop.name = 'pattern'
        prop.value = "This page is importable."
        prop.updateable = false
      }
      
      o.create_event('compile') { |e|
        line = e.args.line
        page = line.parent.parent

        raise "This line can only be used at top of page." unless page.is_a?(Page)
        page.importable = true
      }
      
    }

  end # === core
end # === class


