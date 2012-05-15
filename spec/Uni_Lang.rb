
describe "Uni_Lang" do
  

  it "runs" do
    PROGRAM  = %~

      Superhero is a Noun.
      Rocket-Man is a Superhero.
      The real-name of Rocket-Man is Bob.
      The real-job of Rocket-Man is marriage-counselor.
      The real-home of Rocket-Man is "Boise, ID".
        #{' ' * 3}
        I am something.
        I am another thing.

      Import page, /banzai/characters, as CONTENT.
      The second-home of Rocket-Man is the real-home of Rocket-Man.
      The second-job of Rocket-Man is the real-job of Rocket-Man.

    ~

    u =  Uni_Lang.new(PROGRAM) 
    u.run
    u.tree.should == ["Super"]

  end


end # === Uni_Lang

