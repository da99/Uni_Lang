
 
class Code_To_Code_Block
  
  include Parser::Module
  
  def parse
    code_block.lines
  end

end # === class Code_To_Code_Block
