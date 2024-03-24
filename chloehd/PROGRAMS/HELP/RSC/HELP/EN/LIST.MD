### LIST
***
<code><b>LIST</b> [#</b> <var>file_num</var><b>;</b>] [<var>line_number_0</var>][<b>, </b>][<var>line_number_1</var>]</code>

Prints the program to the screen or a file, starting with <code><var>line_number_0</var></code> up to
and including <code><var>line_number_1</var></code>. Also stops program execution and returns control to
the user. In all cases, any further statements in a compound after <code>LIST</code> will be ignored, both in a program and in direct mode.

When listing to the screen, the same control characters are recognised as in the
[`PRINT`](PRINT) statement.

#### Notes
* In Microsoft BASIC, `LIST` will not show line numbers `65531` to `65535` inclusive.
* SE BASIC's line range is currently `[0 to 16383]`.
* There is no `LLIST` command. Instead, `LIST` can be directed to the printer stream  using `LIST #`.

#### Parameters
* <code><var>line_number_0</var></code> and <code><var>line_number_1</var></code> are line numbers in the range `[0 to 65529]` or
  a `.` to indicate the last line edited. The line numbers do not need to exist;
  they specify a range. If the range is empty, nothing is printed.
* The string expression <code><var>file_num</var></code> is a valid stream indicating the file to list
  to.

#### Errors
* A line number is greater than <code>65529</code>: <samp>Syntax error</samp>.
* <code><var>file_num</var></code> has a string value: <samp>Type mismatch</samp>.
