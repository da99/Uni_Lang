

class Line 

  module Module

    attr_reader :number, :code_block, :sentences, :args
    attr_reader :skip
    attr_accessor :parent, :index, :code, :ignore

    def initialize
      @ignore    = false
      @sentences = []
      @args      = {}
      @skip      = 1
      
      yield self

      if !@parent
        raise "No parent stated."
      end

      if !@index
        raise "No index stated. This is the array index of lines in code block."
      end
      
      if !@code
        raise "No text provided for line."
      end
      
      @number    = @index + 1
      
    end

    def match
      return if ignore
      return if not sentences.empty?
			this = self
      @sentences = parent.match_line_to_sentences(self)
    end

    def compile
      return if ignore
      sentences.last.compile self
    end

    def empty?
      code.strip.empty?
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
