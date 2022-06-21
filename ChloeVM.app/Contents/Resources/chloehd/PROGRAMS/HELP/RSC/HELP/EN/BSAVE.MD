### BSAVE
***
<code><b>BSAVE</b> <var>file_spec</var><b>,</b> <var>offset</var><b>,</b> <var>length</var></code>

Saves a region of memory to an image file.

#### Parameters
* The string expression <code><var>file_spec</var></code> is a valid [file specification](#file-specification) indicating the file to write to.
* <code><var>offset</var></code> is a numeric expression in the range `[-32768 to 65535]` indicating the offset into the current [DEF SEG](#DEF-SEG"> segment from where to start reading.
* <code><var>length</var></code> is a numeric expression in the range `[-32768 to 65535]` indicating the number of bytes to read.
* If <code><var>offset</var></code> or <code><var>length</var></code> are negative, their two's complement will be used.

#### Errors
* <code><var>file_spec</var></code> has a numeric value: <samp>Type mismatch</samp>.
* <code><var>file_spec</var></code> contains disallowed characters: <samp>Bad file number</samp> (on <code>CAS1:</code>); <samp>Bad file name</samp> (on disk devices).
* <code><var>offset</var></code> is not in the range `[-32768 to 65535]`: <samp>Overflow</samp>.
* <code><var>length</var></code> is not in the range `[-32768 to 65535]`: <samp>Overflow</samp>.
