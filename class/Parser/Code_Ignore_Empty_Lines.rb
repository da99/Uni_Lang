

class Code_Ignore_Empty_Lines
  
  include Parser::Module

  def parse
    code_block.lines.each { |line|
      if line.empty?
        line.ignore_this
      end
    }

    code_block.lines
  end

end # === class Code_Ignore_Empty_Lines
