### DEEK
***
<code><var>value</var> <b>= DEEK(</b><var>address</var><b>)</b></code>

Returns the 16-bit value of the memory at <code><var>segment</var> \* 16 + <var>address</var></code> where <code><var>segment</var></code> 
is the current segment set with [DEF SEG](DEF-SEG).

#### Parameters
<code><var>address</var></code> is a numeric expression in `[-32768 to 65535]`. Negative values are 
interpreted as their two's complement.
