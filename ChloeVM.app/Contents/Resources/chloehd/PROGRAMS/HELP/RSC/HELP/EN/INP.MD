### INP
***
<code><var>code</var> <b>= INP</b>(<var>port</var>)</code>

Returns the value of a machine port.

#### Parameters
<var>port</var> is a numeric expression in `[0 to 65535]`.

### INSTR
***
<code><var>position</var> <b>= INSTR</b>([<var>start</var>,] <var>parent</var>, <var>chlid</var>)</code>

Returns the location of the first occurrence of the substring <var>chlid</var> in <var>parent</var>.

#### Parameters
* <var>parent</var> and <var>child</var> are string expressions.
* <var>start</var> is a numeric expression in `[1 to 255]`, specifying the starting position from where to look; if not specified, the search starts at character 1.

#### Notes
* If <var>child</var> is not a substring of <var>parent</var> occurring at or before start, `INSTR` returns `0`.
* If the <var>start</var> index is `0` (instead of `1`), it still searches from the beginning.
* If <var>child</var> is empty, it is found right away at the <var>start</var> index.

#### Errors
* <var>start</var> has a string value or parent or child have numeric values: <samp>Type mismatch</samp>.
* <var>start</var> is not in `[-32768 to 32767]`: <samp>Overflow</samp>.
* <var>start</var> is not in `[1 to 255]`: <samp>Illegal function call</samp>.
