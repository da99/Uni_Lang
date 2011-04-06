

module Noun
  
  attr_reader :name, :propertys, :ancestors
  
  def initialize name, props = {}, actions = []
    @name         = name
    @props        = props
    @actions      = actions
    @ancestors = []
    
    @modules = []
    @icrud = {}
    @propertys = {}
  end

  def data_type?
    false
  end
  
  def valid? str, program
    program.nouns.detect { |noun|
      noun.name == str && noun.ancestors.include?(name)
    }
  end
  
  def has? name
    propertys.has_key?(name)
  end

  def set name, val
    propertys[name] = val
  end

  def get name
    raise "Unknown property: #{name.inspect}" unless has?(name)
    propertys[name]
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

end # === module Noun
