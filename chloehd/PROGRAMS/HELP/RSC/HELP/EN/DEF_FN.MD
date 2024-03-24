### DEF FN
***
<code><b>DEF FN</b>[ ]<var>name</var> [<b>(</b> <var>arg_0</var> [<b>,</b> <var>arg_1</var>] ...<b>)</b>] <b>=</b> <var>expression</var></code>

Defines a function called [FN](FN) <var>name</var></code> (or <code>FN<var> name</var></code>: spaces between <code>FN</code> and <code><var>name</var></code> are optional). On calling <code>FN<var>name</var>( ... )</code>, <code><var>expression</var></code> is evaluated with the supplied
parameters substituted. Any variable names used in the function that are not in the argument list refer to the corresponding global variables. The result of the
evaluation is the return value of <code>FN<var>name</var></code>. The type of the return value must be compatible with the type indicated by <code><var>name</var></code>.

#### Example
Create the recursive function `FN F(n)` to calculate the factorial for `n`:

`DEF FN F(N)=VAL (({N*FN F(N-1)} AND N)+({1} AND (N=0)))`

#### Notes
* This statement may only be used on a program line.
* As the function must be a single expression and SE BASIC does not have a
  ternary operator, the only way to define a recursive function that actually
  terminates is by using [VAL](VAL) or [VAL$](VALS).

#### Parameters
* <code><var>name</var></code> must be a legal variable name.
* <code><var>arg_0</var>, <var>arg_1</var>, ...</code> must be legal variable names. These are the parameters of
  the function. Variables of the same name may or may not exist in the program;
  their value is not affected or used by the defined function.
* <code><var>expression</var></code> must be a legal SE BASIC expression.

#### Errors
* The statement is executed directly instead of in a program line: <samp>Illegal        direct</samp>.
* If the type of the return value is incompatible with the type of <code><var>name</var></code>, no       error is raised at the <code>DEF FN</code> statement; however, a <samp>Type mismatch</samp> will be       raised at the first call of <code>FN<var>name</var></code>.
