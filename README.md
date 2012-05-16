
Uni\_Lang
---------

**Note:** Not ready.

A gem that provides the first implementation of The Universal Language.

What is The Universal Language?
-------------------------------

It's not a language.  I don't know what to call
it. However, people love hype over substance/reality. So, as a slave to
the consumer, I use "Universal Language" as the name.  It's suppose to be
more Englishy than HyperTalk, but with an implementation that is simple, ghetto,
and fits in less than 1,000 lines of code. The Factor language (not the platform)
by Slava Pestov opened my mind to the possibility of creating a flexible and powerful
DSL with an easy-to-understand implementation design.  (Apologies to Mr. Pestov
for using his beautiful language and platform to create a ghetto alternative.)

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

Inspiration: [HyperTalk](http://en.wikipedia.org/wiki/HyperTalk) and [Factor](http://www.factorcode.org/).

I had to figure out the base functionality. These are the building blocks
you use to create programs. Forth inspired me since it shows you how
to implement anything using a long block of memory.  
[This includes if/else statements](http://keithdevens.com/weblog/archive/2005/Jan/24/Thinking-Forth).
Arrays, Hashes, Strings, +/-/%/\* etc... They are all there to automate finding 
and storing stuff in a block of memory.

The rest of the design is based on the way most people want a programming to be:
an extension of how they think.
That is why it looks like a toy: It's meant to be a better HyperTalk, not Smalltalk/Factor.
In other words, it's for people who do not want to program.

If you want more power: 
[Smalltalk](http://www.squeak.org/) or [Factor](http://www.factorcode.org/).


Commercial Break:
-----------------

[British Airways](http://www.youtube.com/watch?v=Yxbgm9Bmkzw)

[The Adventures of Buckaroo Banzai](http://www.amazon.com/dp/B00005JKEX/?tag=miniunicom-20)

[Slava Pestov on Factor](http://www.youtube.com/watch?v=f_0QlhYlS8g)

Ending Credits:
--------------

*Written, Produced, and Directed*
by Pacing around and yelling at the World.


The End
-------

....?
