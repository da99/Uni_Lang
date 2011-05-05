

class Code_Ignore_Empty_Lines
  
  include Parser::Module

  def parse
    program.code_block.lines.each { |line|
      if line.empty?
        line.ignore_this
      end
    }

    program.lines
  end

end # === class Code_Ignore_Empty_Lines
