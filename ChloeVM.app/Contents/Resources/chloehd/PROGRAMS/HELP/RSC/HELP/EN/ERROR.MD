### ERROR
***
<code><b>ERROR</b> <var>error_number</var></code>

Raises the error with number <code><var>error_number</var></code>.

#### Parameters
* <code><var>error_number</var></code> is an expression with a numeric value.

#### Errors
* <code><var>error_number</var></code> has a string value: <samp>Type mismatch</samp>.
* <code><var>error_number</var></code> is not in  `[-32768 to 32767]`: <samp>Overflow</samp>.
* <code><var>error_number</var></code> is not in `1 to 255]`: <samp>Illegal function call</samp>.
