

require "class/Not_In_Pattern"

class Sentence

  module Module

    Done_Line = "! Done :)"
    No_Match = Class.new(RuntimeError)

    attr_reader :name, :code, :action, :pattern, :pattern_regexp,
      :args, :args_ordered, :replace_pattern, :replace_pattern_regexp, :is_partial
		attr_accessor :full_match, :matched, :has_args

		private :full_match=, :matched=, :has_args=

    def initialize name, code, action = :default
      # === PATTERNS
      space = '\\ {0,}'
      word  = "[^\ ]+[[:alnum:]]"
			arg_pattern   = %r!\[#{space}([^\ ]+)#{space}([^\ ]+)?#{space}\]!
			split_pattern = %r!\[#{space}[^\ ]+#{space}[^\ ]{0,}#{space}\]!

      @action = action
			@full_match = false
      @is_partial = false
      @name = name
      @code = code
      @has_args = false
        
      # @arg_wrappers = code.
      #   split(split_pattern).
      #   map { |piece| Regexp.escape(piece) }
      
			@arg_wrappers = Not_In_Pattern.new(code).gsub(arg_pattern) { |piece|
				Regexp.escape(piece)
			}

      @pattern = @arg_wrappers.gsub(arg_pattern, '(' + word + ')')
      
      @pattern_regexp = Regexp.new(@pattern)

			@replace_pattern = @arg_wrappers.gsub(arg_pattern, word)
      
      @replace_pattern_regexp = Regexp.new(@replace_pattern)

      begin
        arg_pairs = code.scan(arg_pattern) # => [ [ 'Noun', nil ] ,  [ 'Word', 'URL' ]  ]
        args    = {}
        ordered = []

        arg_pairs.each { |pair|
          type = pair[0]
          label = pair[1] || type

          if args.has_key?(label)
            raise Author_Error, %~"#{label}" already used in: #{code}.~ 
          end
          args[label] = type
          ordered << [label, type]
        }

        self.has_args = !args.empty?
        @args = args
        @args_ordered = ordered
        
        
      end
    end

    def default_action?
      @action === :default
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
      
      # ==============================================
      # ==============================================
      # the_code = line.code_for_sentence_matcheing
      # the_offset = []
      # 
      # the_code.scan(pattern_regexp) { |matches|
      #   
      #   args           = []
      #   args_with_vals = []
      #   
      #   # Don't use the match if sentence has no arguments.
      #   #   Examples: This page is importable.
      #   #   The scan would return for matches: "This page is importable"
      #   if not matches.is_a?(String)
      #     args = args + matches
      #   end

      #   if self.has_args 
      #     pairs = args.zip(args_ordered)
      #     args_with_vals << pairs.inject({}) { |memo, pair|
      #       memo[pair[0]] = pair[1][0]
      #       memo
      #     }
      #   end
      #   
      #   args_with_vals.each { |hash|
      #     line.args.merge! hash
      #   }
      #   
      #   compile line
  
      #   the_offset << $~.offset(0).first if !the_offset.first
      #   the_offset << $~.offset(0).last
      #   
      #   
      # }

      # self.matched = !the_offset.empty?
      # self.full_match = the_offset.first == 0 && the_offset.last == the_code.size
      # 
      # (line.sentences << self) if self.matched
      # 
      # self.matched
    end
		
  end # === module 
  
  include Module

end # === class
