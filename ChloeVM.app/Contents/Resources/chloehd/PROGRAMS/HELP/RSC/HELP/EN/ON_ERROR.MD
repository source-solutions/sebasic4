### ON ERROR
***
<code><b>ON ERROR GOTO</b> {<var>line_number</var>|<b>0</b>}</code>

Turns error trapping on or off. When <code><var>line_number</var></code> is set, any error causes the error handling routine starting at that line number to be called; no message is printed and program execution is not stopped. The error handling routine is ended by a [](#RESUME">RESUME</a></code> statement. While in an error handling routine, events are paused and error trapping is disabled. After the <code>RESUME</code> statement, any triggered events are picked up in the following order: <code>KEY</code>, <code>TIMER</code>, <code>PLAY</code> - the order of the others is unknown. Unlike event trapping, error trapping remains active when no program is running. <code>ON ERROR GOTO 0</code> turns off error trapping.

#### Parameters
<code><var>line_number</var></code> is an existing line number in the program.

#### Notes
It is not possible to start the error handler at line number <code>0</code>.

#### Errors
<code><var>line_number</var></code> does not exist: <samp>Undefined line number</samp>.
