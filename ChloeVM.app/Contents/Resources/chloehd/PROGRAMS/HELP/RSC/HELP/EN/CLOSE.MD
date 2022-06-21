### CLOSE
***
<code><b>CLOSE</b> [[<b>#</b>] <var>file_0</var> [<b>,</b> [<b>#</b>] <var>file_1</var>] ...]</code>

Closes streams. If no file numbers are specified, all open streams `[3 to 15]` are closed. The hash (`#`) is optional and has no effect.

#### Parameters
<code><var>file_1</var>, <var>file_2</var>, ...</code> are numeric expressions yielding stream numbers.

#### Errors
* <code><var>file_1</var>, <var>file_2</var>, ...</code> are not in `[0 to 15]`: <samp>Bad I/O device</samp>.
* <code><var>file_1</var>, <var>file_2</var>, ...</code> are not open streams: <samp>Undefined stream</samp>.
* <code><var>file_1</var>, <var>file_2</var>, ...</code> have a string value: <samp>Type mismatch</samp>.
* The statement ends in a comma, <samp>Syntax error</samp>.
* If an error occurs, only the files before the erratic value are closed.
