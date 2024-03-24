### OPEN
***
<code><b>OPEN #</b> <var>file_num</var>, "<var>mode_char</var>" [,<var>file_spec</var>]</code>

Opens a data file on a device.

#### Parameters
* The string expression <var>file_spec</var> is a valid [file specification](#file-specification).
* <var>file_num</var> is a valid stream `[3 to 15]`.
* <var>mode_char</var> is a string expression of which the first character is one of:
  * [`"K"`, `"S"`] - system channel (keyboard or screen).
  * [`"I"`, `"O"`, `"A"`, `"R"`] - [`ACCESS`](ACCESS) mode for a disk file.
  * other alpha character - a used defined channel.