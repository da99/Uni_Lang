
class Noun
  class Event
    class Run
      
      module Module
        
        attr_accessor :name, :parent_noun, :action
        attr_reader   :before, :after, :args, :describes
        
        def initialize name
          @name   = name
          @parent_noun = nil
          @action = nil
          @before = []
          @after  = []
          yield(self)
        end
        
        def describes
          @describes ||= parent_noun.in_scope('event describes', name)
        end

        def args
          @args ||= begin
                      keys = describes.map(&:args).flatten.uniq

                      a = Class.new {
                        attr_accessor :original, *keys
                      }.new

                      a.original = keys
                      
                      a
                    end
        end
        
        def run
          
          required = describes.map(&:require_args).flatten.uniq
          missing = required.select { |key|
            !args.send(key)
          }
          
          if not missing.empty?
            raise "Following are required arguments: #{missing.inspect}"
          end
          
          before.each { |b|
            parent_noun.named(b).action.call(self)
          }
          
          action.call(self)
          
          after.each { |b|
            parent.named(b).action.call(self)
          }
          
        end

      end # === module

      include Module

    end # === class Run
  end # === class Event
end # === class Noun
