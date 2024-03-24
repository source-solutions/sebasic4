### INSTR
***
<code><var>position</var> <b>= INSTR</b>([<var>start</var>,] <var>parent</var>, <var>chlid</var>)</code>

Returns the location of the first occurrence of the substring <code><var>chlid</var></code> in <code><var>parent</var></code>.

#### Parameters
* <code><var>parent</var></code> and <code><var>child</var></code> are string expressions.
* <code><var>start</var></code> is a numeric expression in `[1 to 255]`, specifying the starting position
  from where to look; if not specified, the search starts at character 1.

#### Notes
* If <code><var>child</var></code> is not a substring of <code><var>parent</var></code> occurring at or before start, `INSTR` 
  returns `0`.
* If the <code><var>start</var></code> index is `0` (instead of `1`), it still searches from the beginning.
* If <code><var>child</var></code> is empty, it is found right away at the <code><var>start</var></code> index.

#### Errors
* <code><var>start</var></code> has a string value or parent or child have numeric values: <samp>Type mismatch</samp>
* <code><var>start</var></code> is not in `[-32768 to 32767]`: <samp>Overflow</samp>.
* <code><var>start</var></code> is not in `[1 to 255]`: <samp>Illegal function call</samp>.
