### SOUND
***
<code><b>SOUND</b> <var>frequency</var><b>,</b> <var>duration</var></code>

Produces a sound at <code><var>frequency</var></code> Hz for <code><var>duration</var>/18.2</code> seconds.

#### Parameters
<code><var>frequency</var></code> is a numeric expression in `[-60 to 70]`.

#### Errors
* Any argument has a string value: <samp>Type mismatch</samp>.
* <code><var>frequency</var></code> is not in its allowed range, and <code><var>duration</var></code> is not zero: <samp>Illegal function call</samp>.
* <code><var>duration</var></code> is zero and more than two arguments are specified: <samp>Syntax error</samp>.
* <code><var>frequency</var></code> is not in `[-60 to 70]`: <samp>Overflow</samp>.
* <code><var>duration</var></code> is not in `[0 to 10]`: <samp>Illegal function call</samp>.
