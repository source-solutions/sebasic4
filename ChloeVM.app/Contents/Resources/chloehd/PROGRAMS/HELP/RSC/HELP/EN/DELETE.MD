### DELETE
***
<code><b>DELETE</b> [<var>line_number_0</var>|<b>.</b>] [<b>-</b>[<var>line_number_1</var>|<b>.</b>] ]</code>

Deletes a range of lines from the program. Also stops program execution and
returns control to the user.

#### Parameters
* <code><var>line_number_0</var></code> and <code><var>line_number_1</var></code> are line numbers in the range `[0 to 65529]`,
  specifying the inclusive range of line numbers to delete.
* A `.` indicates the last line edited.
* If the start point is omitted, the range will start at the start of the
  program.
* If the end point is omitted, the range will end at the end of the program.
* If no range is specified, the whole program will be deleted.

#### Errors
* <code><var>line_number_0</var></code> or <code><var>line_number_1</var></code> is greater than `65529`: <samp>Syntax error</samp>.
* The range specified does not include any program lines stored: <samp>Illegal          function call</samp>.
