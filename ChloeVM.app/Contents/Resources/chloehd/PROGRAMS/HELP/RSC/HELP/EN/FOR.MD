### FOR
***
<code><b>FOR</b> <var>loop_var</var> <b>=</b> <var>start</var> <b>TO</b> <var>stop</var> [<b>STEP</b> <var>step</var>]</code>

Initiates a `FOR` to `NEXT` loop.

Initially, <code><var>loop_var</var></code> is set to <code><var>start</var></code>. Then, the statements between the `FOR` 
statement and the [`NEXT`](#NEXT) statement are executed and <code><var>loop_var</var></code> is incremented by 
<code><var>step</var></code> (if <code><var>step</var></code> is not specified, by `1`). This is repeated until <code><var>loop_var</var></code> has 
become greater than <code><var>stop</var></code>. Execution then continues at the statement following 
`NEXT`. The value of <code><var>loop_var</var></code> equals <code><var>stop</var></code>+<code><var>step</var></code> after the loop.

#### Parameters
* <code><var>loop_var</var></code> is a numeric variable.
* <code><var>start</var></code>, <code><var>stop</var></code> and <code><var>step</var></code> are numeric expressions.

#### Errors
* No <code>NEXT</code> statement is found to match the <code>FOR</code> statement: <samp>FOR without NEXT</samp> occurs  at the <code>FOR</code> statement.
* <code><var>loop_var</var></code> is a string variable or <code><var>start</var></code>, <code><var>stop</var></code>, or <code><var>end</var></code> has a string value: <samp>Type   mismatch</samp>.
* <code><var>loop_var</var></code> is an array element: <samp>Syntax error</samp>.
* <code><var>loop_var</var></code> is an integer variable and a <code><var>start</var></code>, <code><var>stop</var></code> or <code><var>step</var></code> is outside the range  `[-32768, 32767]`: <samp>Overflow</samp>.
