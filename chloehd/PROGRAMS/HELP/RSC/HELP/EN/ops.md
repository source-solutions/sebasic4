## Operators
***
### Order of precedence
The order of precedence of operators is as follows, from tightly bound (high
precedence) to loosely bound (low precedence):

10\. `^` \
 9\. `*` `/` \
 8\. `\` \
 7\. `MOD` \
 6\. `+` `-` (unary and binary) \
 5\. `=` `<>` `<` `>` `<=` `>=` \
 4\. `NOT` (unary) \
 3\. `AND` \
 2\. `OR` \
 1\. `XOR`

Unlike Microsoft BASIC, `EQV` and `IMP` are not supported. SE BASIC converts the
alternates for <var>not equal</var> (`><`), <var>greater than or equal</var> (`=<`) or <var>less than or equal</var>
(`=>`) to standard notation. Expressions within parentheses are evaluated first.
All binary operators are left-associative: operators of equal precedence are
evaluated left to right.

#### Exponentiation examples
* More tightly bound than negation: `-1^2 = -(1^2) = -1` but `(-1)^2 = 1`.
* Left-associative: `2^3^4 = (2^3)^4 = 4096`.

#### Errors
* If any operator other than `+`, `-` or `NOT` is used without a left operand, an
  error is raised.
* At the end of a statement, if any operator is used without a right operand, an
  error is raised. If this occurs elsewhere inside a statement, such as within
  brackets, an error is raised.