### OPEN
***
<code><b>OPEN #</b><var>file_num</var>, "<var>mode</var>" [,<var>file_spec</var>]</code>

Opens a data file on a device.

#### Parameters
* The string expression <var>file_spec</var> is a valid [file specification](#file-specification).
* <var>file_num</var> is a valid stream `[3 to 15]`.
* <var>mode</var> is a string expression of which the first character is one of:
  * `["K", "S"]` - system channel (keyboard or screen).
  * `["I", "O", "A", "R"]` - [access mode](#access-modes) for a disk file.
  * other alpha character - a used defined channel.

#### Access modes

<var>mode</var> | Meaning | Effect
-----|---------|----------------------------------------------------------------
`"I"`  | INPUT   | Open text file for reading and position file pointer at start.
`"O"`  | OUTPUT  | Truncates a text file at the start and opens it for writing.
`"A"`  | APPEND  | Opens a text file for writing at the end of any existing data.
`"R"`  | RANDOM  | Opens a file for random access.

A single character can be read with <code>c$=INKEY$ #<var>file_num</var></code> or written with
<code>PRINT #<var>file_num</var>;c$;</code>. Strings are terminated with a carriage return. A string can
be read with <code>INPUT #<var>file_num</var>;s$</code> or written with <code>PRINT #<var>file_num</var>;s$</code>.

#### Errors

* <var>file_num</var> is a non-existent stream: <samp>Undefined stream</samp>.
* <var>file_num</var> is not in range `[0 to 15]`: <samp>Bad I/O device</samp>.
* <var>mode_char</var> is a non-existent channel: <samp>Undefined channel</samp>.
* <var>file_spec</var> is non-existent in input or append mode: <samp>File not found</samp>.




