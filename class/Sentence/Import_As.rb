

class Import_As
  
  include Sentence::Module

  def initialize
    super 'import-as', "Import page as [Word Name]: [Word Address]"
  end

  def compile line
    name    = line.args.index('Name')
    address = line.args.index('Address')
    code_block = line.code_block

    code_block.import address, name
  end

end # === class Noun_Create
