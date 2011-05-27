

require "class/Not_In_Pattern"

class Sentence

  module Module

    Done_Line = "! Done :)"
    No_Match = Class.new(RuntimeError)

    attr_reader :name, :patterns, :action, :args, :args_ordered
		attr_accessor :full_match, :matched, :has_args

		private :full_match=, :matched=, :has_args=

    def initialize 
      
      @name     = nil
      @patterns = []
      @action   = nil

      yield self

      %w{ name action }.each { |attr|
        raise "#{attr.capitalize} is required." unless send(attr)
      }
      
      raise "Code is required." if patterns.empty
      
      this = self
      patterns.each { |txt|
        patterns << Sentence_Pattern.new(this, code)
      }
      
    end

    def match_line_and_compile line

      begin
        line.args.clear
        match = line.code_for_sentence_matcheing.match(pattern_regexp)
        
        if match
          the_code = line.code_for_sentence_matcheing
          pos            = match.offset(0)
          args           = match.captures
          
          self.matched = true
          self.full_match = pos.last == the_code.size
          line.sentences << self
        
          if !args.empty?
            
            new_args = args.zip(args_ordered).inject({}) { |memo, pair|
              
              val  = line.carry_over_args[pair.first] || pair.first
              name = pair[1].first
              type = pair[1].last
              
              memo[name] = Argument.new { |o|
                o.name         = name
                o.target_class = type
                o.value        = val
                o.code         = val
              }
              
              memo
            }
            
            line.args.merge! new_args
            
          end
          
          compile line
          
          if self.full_match
          elsif the_code != line.code_for_sentence_matcheing
          else # partial match with no update to code
            raise "This functionality not done."
            
            the_code = line.code_for_sentence_matcheing
            # Code has not been changed. 
            # Next time, match only the next part of the code string.
            starting_pos = pos.last
          end
          
        end
      end while match && !self.full_match
      
    end
		
    def add_arguments type_and_name_array
      
      raise "Code has different arguments to: #{code}, #{other}"
      
      self.has_args = !type_and_name_array.empty?
      type_and_name_array.each { |pair|
        type = pair[0]
        label = pair[1] || type

        if args.has_key?(label)
          raise Author_Error, %~"#{label}" already used in: #{code}.~ 
        end
        args[label] = type
        ordered << [label, type]
      }
    end

  end # === module 
  
  include Module

end # === class
