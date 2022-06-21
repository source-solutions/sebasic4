### WHILE
***
<code><b>WHILE</b> <var>expr</var></code>

Initiates a `WHILE-WEND` loop. If expr evaluates to zero, `WHILE` jumps to the
statement immediately after the matching [`WEND`](#WEND). If not, execution continues.

#### Parameters
`expr` is a numeric expression.

#### Errors
* No matching `WEND` is found: <samp>WHILE without WEND</samp>.
* `expr` has a string value: <samp>Type mismatch</samp>.
