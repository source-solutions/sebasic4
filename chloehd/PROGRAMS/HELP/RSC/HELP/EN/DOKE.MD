### DOKE
***
<code><b>DOKE</b> <var>address</var><b>,</b> <var>value</var></code>

Sets the 16-bit value of the memory byte pair at <code><var>segment</var> \* 16 + <var>address</var></code> to
<code><var>value</var></code>, where <code><var>segment</var></code> is the current segment set with [`DEF SEG`](DEF-SEG).

#### Parameters
* <code><var>address</var></code> is a numeric expression in `[0 to 65535]`. Negative values are
  interpreted as their two's complement.
* <code><var>value</var></code> is a numeric expression in `[0 to 65535]`.

#### Notes
* `DEF SEG` is not yet implemented in SE BASIC.

#### Errors
* <code><var>address</var></code> or <code><var>value</var></code> has a string value: <samp>Type mismatch</samp>.
* <code><var>address</var></code> is not in `[-32768 to 65535]`: <samp>Overflow</samp>.
* <code><var>value</var></code> is not in `[-32768 to 32767]`: <samp>Overflow</samp>.
* <code><var>value</var></code> is not in `[0 to 65535]`: <samp>Illegal function call</samp>.
