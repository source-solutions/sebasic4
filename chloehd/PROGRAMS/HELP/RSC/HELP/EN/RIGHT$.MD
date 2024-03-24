### RIGHT$
***
<code><var>child</var> <b>= RIGHT$(</b><var>parent</var>, <var>num_chars</var><b>)</b></code>
Returns the rightmost <var>num_chars</var> characters of <var>parent</var>.

#### Parameters
* <var>parent</var> is a string expression.
* <var>num_chars</var> is a numeric expression in `[0 to 255]`.

#### Notes
* If <var>num_chars</var> is zero or <var>parent</var> is empty, `RIGHT$` returns an empty string.
* If <var>num_chars</var> is greater than the length of <var>parent</var>, returns <var>parent</var>.

#### Errors
* <var>parent</var> has a numeric value or <var>num_chars</var> has a string value: <samp>Type mismatch</samp>.
* <var>num_chars</var> is not in `[-32768 to 32767]`: <samp>Overflow</samp>.
* <var>num_chars</var> is not in `[0 to 255]`: <samp>Illegal function call</samp>.
