
Uni\_Lang
---------

**Note:** Not ready.

A gem that provides the first implementation of The Universal Language.

What is The Universal Language?
-------------------------------

It's not a language.  I don't know what to call
it. However, people love hype over substance/reality. So, as a slave to
the consumer, I use "Universal Language" as the name.  It's suppose to be
more Englishy than [HyperTalk](http://en.wikipedia.org/wiki/HyperTalk),
but with an implementation that is simple
enough for anyone to understand. The [Factor language](http://www.factorcode.org/)
(not the platform)
by Slava Pestov proved to me that simplicity and power is not only possible,
but the only way to design anything.  (Apologies to Mr. Pestov
for using his beautiful ideas as inspiration for a ghetto abomination.)

If you want more power: 
[Smalltalk](http://www.squeak.org/) or [Factor](http://www.factorcode.org/).


Usage:
-----

    u = Uni_Lang.new(%~
      Val is 1
      Val + 5
    ~)
    u.run
    u.stack
    
    # --> ["1", 6.0]
  
Implementation:
---------------

The rest of the design is based on the way most people want programming to be:
an extension of how they think.
That is why it looks like a toy: It's meant to be a better HyperTalk, not Smalltalk/Factor.
In other words, it's for people who do not want to program.

### Parsing:

Uses the [Walt](https://github.com/da99/Walt):

    This is a line.
    This line is continued
      here.
    This one has a block:

      Content goes here.

### Core Functionality Implementation in Native Language:

One of the harder problems to solve was figuring out the core functionality
that will serve as the building blocks
you use to create programs. Forth inspired me since it shows you how
to implement anything using a long block of memory.  
[This includes if/else statements](http://keithdevens.com/weblog/archive/2005/Jan/24/Thinking-Forth).
Arrays, Hashes, Strings, Classes, etc... They are all there to automate finding 
and storing stuff in a block of memory.

### Implementation of Classes:

A KVI data structure for implementation of prototype-based classes:

    {
      'name' : 'Paragraph',
      'class ancestors' : { 'Web-Page-Element', 'Display-As-Block' }
    }

### Scope:

Each scope has a `stack` as a KVI. 

### Content and Logic Integration:

    New default column named, "First".
    Default link *!von to: http://www.mises.org/.
    Default link *!LRC to: http://www.lewrockwell.com/.
    
    A new paragraph, named "Physics", with content:

      I love *!Holoscience!. I check the TPOD
      everyday on *(Thunderbolts.info). I found
      out about the theory over at *!LRC.

    Set key, "styles", to: electric_uni links.
    Link *!...! to: http://www.holoscience.com/.
    Link *(...) to: http://www.thunderbolts.info/.

    A new paragraph, named "Economics":

      Set key, "styles", to: econ links.
      
      Content is:

        I read *!von and *!LRC.

The use of a `values` and `objects` is what makes the above concise and non-repetitive.
In order to avoid the constant use of `dup` and `dip`, I use
implied functions to search for values on the `stack` and `dup` it:

    Add to styles: links.
    Print last of Stack.

The 1st line alters last item in the `objects` stack.
The 2nd line uses the last item in the `values` stack.

### Defining a Procedure:

This is simpler for the masses to understand than to confuse them
with terms like `method` and `function`.

    Create procedure named, "Add_2".
      
      Add 2 to [...]

    Block is:

      2 + first Args

### Matching against non-String, non-Num values:

The last major problem was matching procedures to lines
containing objects more complex than Strings or Nums:

    Add old-list to new-list.
    Name it: new-list.

Here, `old-list` and `new-list` are lists of numbers
that will be added together. The new list will be placed 
on the `values` and `objects` stack.

    [ 1 , 2 , 3 ]
    [ 4 , 5 , 6 ]
    # ---> [ 1, ..., 6 ]

The procedure used has a pattern: 

    Add [WORD] to [WORD]

The pattern is processed into two values: a **regexp** and an **array**.

    1: %r!Add (...) to (...)!
    2: [ [ "Add", "to" ], 2 ]

The line is matched to the first **regexp**. If that does not work, then
it is matched to the **array**.

    Add old-list to new-list.
    --> match regexp: %r!Add (...) to (...)!
    --> match array:  [['Add', 'to'], [obj, obj].size ]

Type checking is done within the procedure:

    Pass if first Arg has non-num keys.
    Pass if second Arg has non-num keys.

Commercial Break:
-----------------

[British Airways](http://www.youtube.com/watch?v=Yxbgm9Bmkzw)

[The Adventures of Buckaroo Banzai](http://www.amazon.com/dp/B00005JKEX/?tag=miniunicom-20)

[Slava Pestov on Factor](http://www.youtube.com/watch?v=f_0QlhYlS8g)

Ending Credits:
--------------

*Written, Produced, and Directed* <br />
by reading, pacing around, and thinking.


The End
-------

....?
