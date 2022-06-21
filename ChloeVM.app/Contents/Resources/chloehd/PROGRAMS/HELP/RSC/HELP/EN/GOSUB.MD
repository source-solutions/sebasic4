### GOSUB
***
<code><b>GO</b>[ ]<b>SUB</b> <var>line_number</var> [<var>anything</var>]</code>

Jumps to a subroutine at <code><var>line_number</var></code>. The next [](#RETURN">RETURN</a></code> statement jumps back to the statement after `GOSUB`. Anything after <code><var>line_number</var></code> until the end of the statement is ignored. If executed from a direct line, `GOSUB` runs the subroutine and the following `RETURN` returns execution to the direct line.

#### Parameters
* <code><var>line_number</var></code> is an existing line number literal.
* Further characters on the line are ignored until end of statement.

#### Notes
* If no `RETURN` is encountered, no problem.
* One optional space is allowed between <code>GO</code> and <code>SUB</code>; it will not be retained in the program.

#### Errors
* If <code><var>line_number</var></code> does not exist: <samp>Undefined line number</samp>.
* If <code><var>line_number</var></code> is greater than <code>65529</code>, only the first 4 characters are read (for example, <code>6553</code>)
