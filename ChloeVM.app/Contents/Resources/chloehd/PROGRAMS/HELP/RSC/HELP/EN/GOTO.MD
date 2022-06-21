### GOTO
***
<code><b>GOTO</b> <var>line_number</var> [<var>anything</var>]</code>

Jumps to <code><var>line_number</var></code>.  Anything after <code><var>line_number</var></code> until the end of the statement is ignored. If executed from a direct line, <code>GOTO</code> starts execution of the program at the specified line.

#### Parameters
* <code><var>line_number</var></code> is an existing line number literal.
* Further characters on the line are ignored until end of statement.

#### Notes
No spaces are allowed between <code>GO</code> and <code>TO</code>.

#### Errors
* <code><var>line_number</var></code> does not exist: <samp>Undefined line number</samp>.
