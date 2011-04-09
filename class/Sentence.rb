

class Sentence

  module Module

    Done_Line = "! Done :)"
    No_Match = Class.new(RuntimeError)

    attr_reader :name, :code, :action, :pattern, :pattern_regexp,
      :args, :args_ordered, :replace_pattern, :replace_pattern_regexp, :is_partial

    def initialize name, code, action = :default
      # === PATTERNS
      space = '\\ {0,}'
      word  = "[^\ ]+"
      arg_pattern = %r!\[#{space}([^\ ]+)#{space}([^\ ]+)?#{space}\]!
      split_pattern = %r!\[#{space}[^\ ]+#{space}[^\ ]{0,}#{space}\]!

      @action = action
      @is_partial = false
      @name = name
      @code = code

      @arg_wrappers = code.
        split(split_pattern).
        map { |piece| Regexp.escape(piece) }

      @pattern = @arg_wrappers.
        join('(' + word + ')') 
      @pattern_regexp = Regexp.new(@pattern)

      @replace_pattern = @arg_wrappers.join(word)
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

    def match_line index, program

      line = program.lines[index]

      args = line.code.scan(pattern_regexp)

      return line if args.empty?
      #   raise No_Match, "#{line.code} |->| #{code}"
      # end

      args_with_vals = []

      args.each { |each_match|
        pairs = each_match.zip(args_ordered)
        args_with_vals << pairs.inject({}) { |memo, pair|
          memo[pair[0]] = pair[1][0]
          memo
        }
      }

      line.sentences << self
      line.updates << line.code.gsub(replace_pattern_regexp, Done_Line)
      args_with_vals.each { |hash|
        line.args.merge! hash
      }

      line
    end

  end # === module 
  
  include Module

end # === class
