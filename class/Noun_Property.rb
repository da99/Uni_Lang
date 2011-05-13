

class Noun_Property
  
  module Module

		attr_accessor :name, :value, :updateable

    def initialize 
			@updateable = false
			yield(self)
			raise "Name not set." unless @name
    end
		
  end # === module

  include Module
  
end # === class Noun
