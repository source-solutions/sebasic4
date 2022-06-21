### RETURN
***
<code><b>RETURN</b> [<var>line</var>]</code>

Returns from a [GOSUB](#GOSUB) subroutine. If <code><var>line</var></code> is not specified, `RETURN` jumps back to the statement after the `GOSUB` that jumped into the subroutine. If <code><var>line</var></code> is specified, it must be a valid line number. `RETURN` jumps to that line (and pops the `GOSUB` stack). When returning from an error trapping routine, `RETURN` re-enables the event trapping which was stopped on entering the trap routine.

#### Errors
<code><var>line</var></code> is not an existing line number: <samp>Undefined line number</samp>.
