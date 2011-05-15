

class Page_Is_Importable
  
  include Sentence::Module

  def initialize
    super 'page-is_importable', "This page is importable."
  end

  def compile line
    page = line.parent.parent

    raise "This line can only be used at top of page." unless page.is_a?(Page)
    page.importable = true
  end

end # === class Noun_Create
