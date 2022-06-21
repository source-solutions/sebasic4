### OUT
***
<code><b>OUT</b> <var>port</var><b>,</b> <var>value</var></code>

Sends a byte to an emulated machine port.

#### Parameters
* <code><var>port</var></code> is a numeric expression in `[0 to 65535]`.
* <code><var>value</var></code> is a numeric expression in `[0 to 255]`.

#### Errors
* <code><var>port</var></code> or <code><var>value</var></code> has a string value: <samp>Type mismatch</samp>.
* <code><var>port</var></code> is not in `[0 to 65535]`: <samp>Overflow</samp>.
* <code><var>value</var></code> is not in `[0 to 32767]`: <samp>Overflow</samp>.
* <code><var>value</var></code> is not in `[0 to 255]`: <samp>Illegal function call</samp>.
