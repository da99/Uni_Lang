

class Line 

  module Module

    attr_reader :number, :index, :code, :program, :sentences, :args
    attr_reader :updates, :skip

    def initialize raw_index, code, program
      @number    = raw_index + 1
      @index     = raw_index
      @code      = code
      @ignore    = false
      @program   = program
      @sentences = []
      @updates   = []
      @args      = {}
      @skip      = 1
    end

    def match
      return if ignore?
      return if not sentences.empty?

      program.sentences.each { |sentence|
        sentence.new.match_line( index, program )
        break if full_match?
      }

      not sentences.empty?
    end

    def compile
      return if ignore?
      sentences.last.compile self
    end

    def empty?
      code.strip.empty?
    end

    def ignore?
      @ignore
    end

    def ignore_this
      @ignore = true
    end

    def matched?
      not updates.empty?
    end

    def full_match?
      matched? && updates.last == Sentence::Done_Line
    end

    def partial_match?
      matched? && !full_match?
    end

    def skip_next num
      @skip += num
    end

  end # === module

  include Module

end # === class Line
