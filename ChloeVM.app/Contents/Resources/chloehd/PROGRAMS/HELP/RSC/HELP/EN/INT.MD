### INT
***
<code><var>whole</var> <b>= INT(</b><var>number</var><b>)</b></code>

Returns <code><var>number</var></code> truncated towards negative infinity.

#### Parameters
<code><var>number</var></code> is a numeric expression.

#### Notes
[FIX](#FIX) truncates towards zero: it removes the fractional part. By contrast, `INT` truncates towards negative infinity.

#### Errors
<code><var>number</var></code> is a string expression, <samp>Type mismatch</samp>.
