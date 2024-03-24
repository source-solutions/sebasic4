### ASC
***
<code><var>val</var><b> = ASC(</b><var>char</var><b>)</b></code>

Returns the [code point](Technical-reference#Codepage-437) (ASCII value) for the first character of <code><var>char</var></code>.

#### Parameters
<code><var>char</var></code> is an expression with a string value.

#### Errors
* <code><var>char</var></code> has a numeric value: <samp>Type mismatch</samp>.
* <code><var>char</var></code> equals `""`: <samp>Illegal function call</samp>.
