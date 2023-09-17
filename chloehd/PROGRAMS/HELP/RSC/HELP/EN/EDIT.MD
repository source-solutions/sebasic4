### EDIT
***
<code><b>EDIT</b> {<var>line_number</var>|<b>.</b>}</code>

Displays the specified program line with the cursor positioned for editing.
<code><var>line_number</var></code> must be a line that exists in the program, or a period (.) to 
indicate the last line stored.

#### Errors
* No line_number is specified: <samp>Undefined line number</samp>.
* More characters are written after the line number: <samp>Illegal function call</samp>.
* <code><var>line_number</var></code> is not in `[0 to 65529]` <samp>Illegal function call</samp>.
* The specified line number does not exist: <samp>Undefined line number</samp>.
