### STRING$
***
<code><var>string</var> <b>= STRING$(</b><var>length</var>, <var>char</var><b>)</b></code>

Returns a string of <code><var>length</var></code> times the character <code><var>char</var></code>.

#### Parameters
* If <code><var>char</var></code> is a numeric expression, it must be in `[0 to 255]` and is interpreted 
  as the [code point](code-point) of the character.
* If <code><var>char</var></code> is a string expression, its first character is used.

#### Errors
* <code><var>length</var></code> has a string value: <samp>Type mismatch</samp>.
* <code><var>char</var></code> is the empty string: <samp>Illegal function call</samp>.
* <code><var>char</var></code> or <code><var>length</var></code> is not in `[-32768 to 32767]`: <samp>Overflow</samp>.
* <code><var>char</var></code> or <code><var>length</var></code> is not in `[0 to 255]`: <samp>Illegal function call</samp>.
