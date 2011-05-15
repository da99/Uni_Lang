

class Import_As
  
  include Sentence::Module

  def initialize
    super 'import-as', "Import page as [Word Name]: [Word Address]"
  end

  def compile line
    name    = line.args.index('Name')
    address = line.args.index('Address')
    line.parent.import address, name
  end

end # === class Noun_Create
