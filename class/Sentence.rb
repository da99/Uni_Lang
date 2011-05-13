

require "class/Not_In_Pattern"

class Sentence

  module Module

    Done_Line = "! Done :)"
    No_Match = Class.new(RuntimeError)

    attr_reader :name, :code, :action, :pattern, :pattern_regexp,
      :args, :args_ordered, :replace_pattern, :replace_pattern_regexp, :is_partial
		attr_accessor :full_match, :matched

		private :full_match=, :matched=

    def initialize name, code, action = :default
      # === PATTERNS
      space = '\\ {0,}'
      word  = "[^\ ]+"
			arg_pattern   = %r!\[#{space}([^\ ]+)#{space}([^\ ]+)?#{space}\]!
			split_pattern = %r!\[#{space}[^\ ]+#{space}[^\ ]{0,}#{space}\]!

      @action = action
			@full_match = false
      @is_partial = false
      @name = name
      @code = code

      @arg_wrappers = code.
        split(split_pattern).
        map { |piece| Regexp.escape(piece) }
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

        @args = args
        @args_ordered = ordered
      end
    end

    def default_action?
      @action === :default
    end 

    def match_line line

      args = line.code.scan(pattern_regexp)

      return false if args.empty?

      args_with_vals = []
			entire_line_matches = args.size == 1 && args.first == line.code

			if not entire_line_matches
				args.each { |each_match|
					pairs = each_match.zip(args_ordered)
					args_with_vals << pairs.inject({}) { |memo, pair|
						memo[pair[0]] = pair[1][0]
						memo
					}
				}
			end

			self.matched = true
			self.full_match = Done_Line == line.code.gsub(replace_pattern_regexp, Done_Line)
      args_with_vals.each { |hash|
        line.args.merge! hash
      }

      true
    end
		
  end # === module 
  
  include Module

end # === class
