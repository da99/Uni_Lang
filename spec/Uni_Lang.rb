
describe "Uni_Lang" do
  

  it "runs" do
    PROGRAM  = %~

      Superhero is a Noun.
      Rocket-Man is a Superhero.
      The real-name of Rocket-Man is Bob.
      The real-job of Rocket-Man is marriage-counselor.
      The real-home of Rocket-Man is Boise,ID.
        #{' ' * 3}
        I am something.
        I am another thing.

      Import page as Content-Code: CONTENT
      The second-home of Rocket-Man is the real-home of Rocket-Man.
      The second-job of Rocket-Man is the real-job of Rocket-Man.

    ~



    require 'Uni_Lang/Noun/Core'
    prog = Uni_Lang::Core::Code_Block.create('my program') { |n|

      n.immutable_property('code', PROGRAM)
      n.immutable_property('file_address', __FILE__)

    }

    prog.run_event('run')


    pp prog.read_property('nouns').map(&:inspect_informally)
  end


end # === Uni_Lang

