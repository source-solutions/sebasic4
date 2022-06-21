### PEEK
***
<code><var>value</var> <b>= PEEK(</b><var>address</var><b>)</b></code>

Returns the value of the memory at  <code><var>segment</var> \* 16 + <var>address</var></code> where <code><var>segment</var></code> 
is the current segment set with [DEF SEG](#DEF-SEG).

#### Parameters
<code><var>address</var></code> is a numeric expression in `[-32768 to 65535]`. Negative values are 
interpreted as their two's complement.

#### Notes
Currently `PEEK` only accepts values in the range `[0 to 65535]` and ignores `SEG`, 
returning values from the 64K address space.

#### Errors
* <code><var>address</var></code> has a string value: <samp>Type mismatch</samp>.
* <code><var>address</var></code> is not in `[-32768 to 65535]`: <samp>Overflow</samp>.
