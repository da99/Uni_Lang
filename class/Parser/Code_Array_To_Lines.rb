

class Code_Array_To_Lines
  
  include Parser::Module

  def parse
    lines = program.code_block.lines
    new_lines  = []
    
    lines.each_index { |index|
      line = lines[index]
      new = if line.is_a?(String)
              Line.new index, line, program
            else
              line
            end
      new_lines << new
    }

    new_lines
  end

end # === Code_Array_To_Lines
