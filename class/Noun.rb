

class Noun
  
  module Module

    attr_reader :propertys, :ancestors, :events
    attr_accessor :name, :importable, :parent

    def initialize 
      @events = []
      @event_describes = []
      @ancestors  = []
      @importable = false
      @propertys  = {}
      @name       = nil
      @parent = nil
      yield(self)
      raise "Name is required." unless self.name
      
      describe_event("creation of a property named [word]") { |d|
        d.before << "creation of any property"
        d.require_args << 'property'
        d.require_action = true
      }
    end
    
    def ancestor_nouns
      ancestors.map { |anc| 
        parent.all('nouns', anc)
      }
    end

    def valid? str, program
      program.nouns.detect { |noun|
        noun.name == str && noun.ancestors.include?(name)
      }
    end

    def inspect_informally
      "#{name} (#{self.class.name}) - #{propertys.map { |pair| pair.first.to_s + ': ' + pair.last.value.to_s }.join(', ') }"
    end

    # === Family Handling ================================
    
    def all type, name  = :dont_filter
      case type
      when 'events'
        list = if name == :dont_filter
                 events + ancestor_nouns.map { |anc| anc.all(type) }
               else
                 events_named( name ) + ancestor_nouns.map { |anc| anc.all(type, name) }
               end
        list.flatten
      when 'event describes'
        raise "Not implemented."
      else
        raise "Unknown type: #{type}"
      end
    end


    # === Events =========================================
    
    def create_event event_name, &blok
      events << Event.new(event_name, &blok) 
    end

    def describe_event name, &blok
      if block_given?
        this = self

        @event_describes << ::Noun::Event::Describe.new(name) { |d|
          d.parent = this
          d.instance_eval( &blok )
        }
      else
        all     = @event_describes + parent.ancestor_nouns.map(&:describes)
        targets = all.select { |desc| desc.name == name }

        ::Noun::Event::Describe.new(name){ |d|
          d.parent = this
          d.consume *targets
        }
      end
    end

    def events_named target
      events.select { |e|
        case target
        when String
          e.name == target
        else
          e.name =~ target
        end
      }
    end

    def run_event name, &blok

      this = self
      e_run = ::Noun::Event::Run.new(name) { |r|
        r.parent = this
        r.instance_eval { blok.call(r) }
      }

      result    = nil
      methods   = named(name)
      overwrite = "overwrite #{name}"
      before    = "before #{name}"
      after     = "after #{name}"

      ow_event = methods.detect { |m| m.name == overwrite }
      b_events  = methods.select { |m| m.name == before }
      a_events  = methods.select { |m| m.name == after }

      return ow_event.run( args ) if ow_event

      b_events.each { |ev|
        ev.run args
      }

      result = e_run.run

      a_events.each { |ev|
        ev.run args
      }

      result
    end
    
    
    # === Propertys ======================================
    
    def create_property &blok
      new_prop = ::Noun::Property.new(&blok) 
      name = new_prop.name
      raise "Property, #{name}, already created." if propertys.has_key?(name)

      run_event("creation of a property named #{name}") { |r|
        r.args.property = new_prop 
        r.action = lambda  do |ir|
          self[name] = new_prop
        end
      }
    end
    
    def property_named name
      raise "Property does not exist: #{name}" unless property_exists?(name)
      propertys[name] 
    end
    
  end # === module

  include Module
  
end # === class Noun
