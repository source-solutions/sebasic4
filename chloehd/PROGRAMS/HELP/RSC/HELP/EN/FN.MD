### FN
***
<code><var>result</var> <b>= FN</b>[ ]<var>name</var> [<b>(</b><var>arg_0</var> [<b>,</b> <var>arg_1</var>] ...<b>)</b></code>

Evaluates the user-defined function previously defined with [`DEF FN`](DEF-FN) <code><var>name</var></code>. 
Spaces between `FN` and <code><var>name</var></code> are required.

#### Parameters
* <code><var>name</var></code> is the name of a previously defined function.
* <code><var>arg_0</var>, <var>arg_1</var>, ...</code> are expressions, given as parameters to the function.

#### Notes
* In Microsoft BASIC, spaces between `FN` and <code><var>name</var></code> are optional.
* Unlike Microsoft BASIC, in SE Basic IV, functions can be called recursively,
  albeit without tail call optimization.

#### Errors
* No function named <code><var>name</var></code> is defined: <samp>Undefined user function</samp>.
* The number of parameters differs from the function definition: <samp>Syntax error</samp>.
* The type of one or more parameters differs from the function definition: <samp>Type   mismatch</samp>.
* The return type is incompatible with the function name's sigil: <samp>Type mismatch</samp>.
