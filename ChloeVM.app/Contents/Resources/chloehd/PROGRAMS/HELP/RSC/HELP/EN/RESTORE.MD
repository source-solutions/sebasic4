### RESTORE
***
<code><b>RESTORE</b> [<var>line</var>]</code>

Resets the [`DATA`](#DATA) pointer. <code><var>line</var></code> is a line number. If <code><var>line</var></code> is not specified, the `DATA` pointer is reset to the first `DATA` entry in the program. If it is
specified, the `DATA` pointer is reset to the first `DATA` entry in or after <code><var>line</var></code>.

#### Errors
<code><var>line</var></code> is not an existing line number: <samp>Undefined line number</samp>.
