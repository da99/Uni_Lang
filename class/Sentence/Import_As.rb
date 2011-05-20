

class Import_As
  
  include Sentence::Module

  def initialize
    super 'import-as', "Import page as [Word Name]: [Word Address]"
  end

  def compile line
    name    = line.args['Name'].value
    address = line.args['Address'].value
    line.parent.import address, name
  end

end # === class Noun_Create
