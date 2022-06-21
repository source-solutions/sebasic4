### WHILE
***
<code><b>WHILE</b> <var>expr</var></code>

Initiates a `WHILE—WEND` loop. If expr evaluates to zero, `WHILE` jumps to the statement immediately after the matching `WEND`. If not, execution continues.

#### Parameters
`expr` is a numeric expression.

#### Errors
* No matching `WEND` is found: <sample>WHILE without WEND</sample>.
* `expr` has a string value: <sample>Type mismatch</sample>.
