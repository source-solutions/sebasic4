### LEFT$
***
<code><var>child</var> <b>= LEFT$(</b><var>parent</var>, <var>num_chars</var><b>)</b></code>

Returns the leftmost <code><var>num_chars</var></code> characters of parent.

#### Parameters
* <code><var>parent</var></code> is a string expression.
* <code><var>num_chars</var></code> is a numeric expression in `[0 to 255]`.

#### Notes
* If <code><var>num_chars</var></code> is zero or <code><var>parent</var></code> is empty, `LEFT$` returns an empty string.
* If <code><var>num_chars</var></code> is greater than the length of <code><var>parent</var></code>, returns <code><var>parent</var></code>.

#### Errors
* <code><var>parent</var></code> has a numeric value or <code><var>num_chars</var></code> has a string value: <samp>Type mismatch</samp>.
* <code><var>num_chars</var></code> is not in `[-32768 to 32767]`: <samp>Overflow</samp>.
* <code><var>num_chars</var></code> is not in `[0 to 255]`: <samp>Illegal function call</samp>.
