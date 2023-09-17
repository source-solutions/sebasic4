### CHR$
***
<code><var>char</var> <b>= CHR$(</b><var>x</var><b>)</b></code>

Returns the character with [code point](Technical-reference#Codepage-437) <code><var>x</var></code>.

#### Parameters
<code><var>x</var></code> is a numeric expression in the range [`0 to 255`].

#### Errors
* <code><var>x</var></code> has a string value: <samp>Type mismatch</samp>.
* <code><var>x</var></code> is not in `[-32768 to 32767]`: <samp>Overflow</samp>.
* <code><var>x</var></code> is not in `0 to 255`: <samp>Illegal function call</samp>.
