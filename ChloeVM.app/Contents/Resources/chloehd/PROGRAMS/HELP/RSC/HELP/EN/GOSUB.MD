### GOSUB
***
<code><b>GO</b>[ ]<b>SUB</b><var>line_number</var> [<var>anything</var>]</code>

Jumps to a subroutine at <code><var>line_number</var></code>. The next [`RETURN`](#RETURN) statement jumps back to the statement after `GOSUB`. Anything after <code><var>line_number</var></code> until the end of the 
statement is ignored. If executed from a direct line, `GOSUB` runs the subroutine and the following `RETURN` returns execution to the direct line.

#### Parameters
* <code><var>line_number</var></code> is an existing line number literal.
* Further characters on the line are ignored until end of statement.

#### Notes
* If no `RETURN` is encountered, no problem.
* One optional space is allowed between `GO` and `SUB`; it will not be retained in
  the program.

#### Errors
* If <code><var>line_number</var></code> does not exist: <samp>Undefined line number</samp>.
* If <code><var>line_number</var></code> is greater than `65529`, only the first four characters are read   (for example, `6553`).
