### Relational operators
***
Relational operators can operate on numeric as well as string operands; however,
if one operand is string and the other numeric, an error is raised.

Relational operators return either `0` (for false) or `-1` for true.


Code    | Operation             | Result
------- | --------------------- | ----------------------------------------------
`=`       | equal                 | True if `a` equals `b`, false otherwise.
`<>` (`><`) | not equal             | False if `a` equals `b`, true otherwise.
`<`       | less than             | True if `a` is less than `b`, false otherwise.
`>`       | greater than          | True if `a` is greater than `b`, false otherwise.
`<=` (`=<`) | less than or equal    | False if `a` is greater than `b`, true otherwise.
`>=` (`=>`) | greater than or equal | False if `a` is less than `b`, true otherwise.

When operating on numeric operands, both operands are compared as floating-point
numbers according to the usual ordering of numbers. The equals operator tests
for equality to within machine precision for the highest-precision of the two
operator types.

When comparing strings, the ordering is as follows.

* Two strings are equal only if they are of the same length and every character
  code of the first string agrees with the corresponding character code of the
  second. This includes any whitespace or unprintable characters.
* Each character position of the strings is compared starting with the leftmost
  character. When a pair of different characters is encountered, the string with
  the character of lesser [code point](#code-poin) is less than the string with
  the character of greater code point.
* If the strings are of different length, but equal up to the length of the
  shorter string, then the shorter string is less than the longer string.

#### Note
The tokenizer converts the symbols `><`, `=>` and `=<` to `<>`, `>=` and `<=` respectively.
