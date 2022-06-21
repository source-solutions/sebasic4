### FIX
***
<code><var>whole</var> <b>= FIX(</b><var>number</var><b>)</b></code>

Returns a <code><var>number</var></code> truncated towards zero.

#### Parameters
<code><var>number</var></code> is a numeric expression.

#### Notes
`FIX` truncates towards zero: it removes the fractional part. By contrast, [`INT`](#INT) 
truncates towards negative infinity.

#### Errors
<code><var>number</var></code> is a string expression: <samp>Type mismatch</samp>.
