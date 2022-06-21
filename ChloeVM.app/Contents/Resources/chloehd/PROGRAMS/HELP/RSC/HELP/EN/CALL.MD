### CALL
***
<code><b>CALL</b> <var>address_var</var> [, <var>p0</var>, <var>p1</var>, ...]</code>

Executes a machine language subroutine.

#### Parameters
* <code><var>address_var</var></code> is a numeric variable.
* <code><var>p0</var>, <var>p1</var>, ...</code> are variables.

#### Errors
* <code><var>address_var</var></code> is a string variable: <samp>Type mismatch</samp>.
* <code><var>address_var</var></code> is a literal: <samp>Syntax error</samp>.
