

class Line 

  module Module

    attr_reader :number, :index, :code, :code_block, :sentences, :args
    attr_reader :skip

    def initialize raw_index, code, code_block
      @number    = raw_index + 1
      @index     = raw_index
      @code      = code
      @ignore    = false
      @code_block   = code_block
      @sentences = []
      @args      = {}
      @skip      = 1
    end

    def match
      return if ignore?
      return if not sentences.empty?
			this = self
      @sentences = code_block.match_line_to_sentences(self)
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
      not sentences.empty?
    end

    def full_match?
      sentences.detect { |sent| sent.full_match }
    end

    def partial_match?
      matched? && !full_match?
    end

    def skip_next num
      @skip += num
    end

    def add_to_code_block str
      @code_block_code ||= []
      @code_block_code << str.sub(/\A  /,'')
    end

  end # === module

  include Module

end # === class Line
