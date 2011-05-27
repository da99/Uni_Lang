
class Event
  
  module Module
    
    attr_reader :arguments
    attr_accessor :name, :condition_proc, :action_proc

    def initialize
      self.arguments = {}
      yield self if block_given?
    end

    def applicable?
      (condition_proc && condition_proc.call(self)) || condition_method
    end

    def action
      if applicable?
        (action_proc && action_proc.call(self)) || action_method
      end
    end

    def condition_method
      raise "This method was meanth to be overwritten."
    end

    def action_method
      raise "This method was meanth to be overwritten."
    end

  end # === module
  
  include Module

end # === class
