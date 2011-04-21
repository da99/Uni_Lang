

class Code_To_Array
  
  include Parser::Module
  
  def parse
    lines = program.lines
    return lines if lines.is_a?(Array)

    program.code.split("\n")
  end

end # === Code_To_Array