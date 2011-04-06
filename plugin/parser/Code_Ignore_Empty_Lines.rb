

class Code_Ignore_Empty_Lines
  
  include Parser

  def parse
    program.lines.each { |line|
      if line.empty?
        line.ignore_this
      end
    }

    program.lines
  end

end # === class Code_Ignore_Empty_Lines
