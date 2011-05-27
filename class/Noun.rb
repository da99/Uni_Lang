

class Noun
  
  module Module

    attr_reader :propertys, :ancestors, :events
		attr_accessor :name, :importable

    def initialize 
      @props     = {}
      @events    = []
      @ancestors = []
			@importable = false
      @modules   = []
      @icrud     = {}
      @propertys = {}
			yield(self)
			raise "Name is required." unless @name

    end

    def data_type?
      false
    end

    def valid? str, program
      program.nouns.detect { |noun|
        noun.name == str && noun.ancestors.include?(name)
      }
    end

    def create_property &blok
			new_prop = Noun_Property.new(&blok) 
			name = new_prop.name
			raise "Property, #{name}, already created." if propertys[name]
			propertys[name] = new_prop
    end
		
		def update_property name, val
			prop = propertys[name]
			raise "Property does not exist: #{name}" unless prop
			raise "Property can not be updated: #{name}" unless prop.updateable
			prop.value = val
		end

		def detect_property_named prop_name
			propertys[prop_name]
		end

    def on_initialize
    end

    def on_create
    end

    def on_read
    end

    def on_update
    end

    def on_delete
    end

    def on_undelete
    end

		def inspect_informally
			"#{name} (#{self.class.name}) - #{propertys.map { |pair| pair.first.to_s + ': ' + pair.last.value.to_s }.join(', ') }"
		end

  end # === module

  include Module
  
end # === class Noun
