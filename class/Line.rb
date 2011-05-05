

class Line 

  module Module

    attr_reader :number, :index, :code, :code_block, :sentences, :args
    attr_reader :updates, :skip

    def initialize raw_index, code, code_block
      @number    = raw_index + 1
      @index     = raw_index
      @code      = code
      @ignore    = false
      @code_block   = code_block
      @sentences = []
      @updates   = []
      @args      = {}
      @skip      = 1
    end

    def match
      return if ignore?
      return if not sentences.empty?

      code_block.sentences.each { |sentence|
        sentence.new.match_line( index, code_block )
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
