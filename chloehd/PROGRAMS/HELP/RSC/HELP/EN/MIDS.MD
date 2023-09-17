### MID$
***
<code><var>substring</var> <b>= MID$(</b><var>string</var>, <var>position</var> [, <var>length</var>]<b>)</b></code>

Returns a substring <code><var>string</var></code> starting at <code><var>position</var></code>, counting from `1`. The substring has length <code><var>length</var></code> if specified. If <code><var>length</var></code> is not specified, the substring 
extends to the end of the string.

#### Parameters
* <code><var>string</var></code> is a string expression.
* <code><var>position</var></code> is a numeric expression between `1` and the string length, inclusive.
* <code><var>length</var></code> is a numeric expression in `[0 to 255]`.

#### Errors
* <code><var>string</var></code> has a number value or position or <code><var>length</var></code> have string values: <samp>Type        mismatch</samp>.
* <code><var>position</var></code> or <code><var>length</var></code> are not in `[-32768 to 32767]`: <samp>Overflow</samp>.
* <code><var>position</var></code> is not in `[1 to 255]`: <samp>Illegal function call</samp>.
* <code><var>length</var></code> is not in `[0 to 255]`: <samp>Illegal function call</samp>.
