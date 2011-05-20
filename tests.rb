
When line is partially matched against all sentences.

New Sentence: Import page as [Word Name]: [Word Address]
	should generate regexp pattern: " /Import\ page\ as\ ([^ ]+):\ ([^ ]+)\/ "
		

Nouns found in other scope are visible if importable is set to true.

Sentence is matched AND compiled, even if it has no arguments.

Sentences matched when defined dynamically.

Sentences are matched by pattern AND data-type.
Sentences are matched by pattern AND data-type WHEN using partial sentences( "prop" of "noun")

Sentences re-matched when partially matched.
  Second match is to match entire line.
  Example: The value of Name of Scope.
  Match 1: Name of Scope
  Match 2: The value of "Match 1".
    
Multiple partials:
  Name of Scope of Page of Uni
  
Defining a sentence that takes 1 or more code blocks as arguments in the
  sentence text, with one of them called "Code Block", but it also
  accepts a code block after the sentence.

Match sentences with whitespace at the end.
Match lines with whitespace at the end.

A partial where it matches a word right before a period:
  The value of something of Something.

This line must match entirely, leaving only a value on the stack:
  value of Something of Something-Bigger.

Line must compile to various sentences that is matches.
  Right now its possible a full match might be skipped:
    full sentence
    partial sentence
    full sentence
  Also, check to see every sentence that matches is run just once.


__END__

Downsides of Uni Lang
  * makes people think computers can think
  * makes people use Regular English instead of a sub-set of English.
  * makes programming look easy.
    This is not programming. 
    It's pattern matching and algorythms
      with a little natural talent.
      If you don't play with legos as 
      an adult, you have no business programming.
      Exceptions: physicists.
