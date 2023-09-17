### ON
***
<code><b>ON</b> <var>n</var> {<b>GOTO</b>|<b>GOSUB</b>} <var>line_number_0</var> [, <var>line_number_1</var>] ...</code>

Jumps to the <code><var>n</var></code>th line number specified in the list. If <code><var>n</var></code> is `0` or greater than
the number of line numbers in the list, no jump is performed. If `GOTO` is
specified, the jump is unconditional; if `GOSUB` is specified, jumps to a
subroutine.

#### Parameters
* <code><var>n</var></code> is a numeric expression in `[0 to 255]`.
* <code><var>line_number_0, line_number_1, ...</var></code> are existing line numbers in the program.

#### Errors
* <code><var>n</var></code> has a string value: <samp>Type mismatch</samp>.
* <code><var>n</var></code> is not in `[-32768 to 32767]`, <samp>Overflow</samp>.
* <code><var>n</var></code> is not in `[0 to 255]`: <samp>Illegal function call</samp>.
* The line number jumped to does not exist: <samp>Undefined line number</samp>.
