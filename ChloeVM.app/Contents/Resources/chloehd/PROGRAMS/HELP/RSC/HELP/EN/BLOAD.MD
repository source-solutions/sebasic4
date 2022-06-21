### BLOAD
***
<code><b>BLOAD</b> <var>file_spec</var><b>,</b> <var>offset</var></code>

Loads a memory image file into memory.

#### Parameters
* The string expression <code><var>file_spec</var></code> is a valid [file specification](#file-specification) indicating the  file to read the memory image from.
* <code><var>offset</var></code> is a numeric expression in the range `[-32768 to 65535]`. It indicates an offset in the current [`DEF SEG`]













segment where the file is to be stored. If not specified, the offset stored in the [`BSAVE`](#BSAVE) file will be used. If negative, its two's complement will be used.

#### Errors
* The loaded file is not in `BSAVE` format: <samp>Bad file mode</samp>.
* <code><var>file_spec</var></code> contains disallowed characters: <samp>Bad file  name</samp>.
* <code><var>file_spec</var></code> has a numeric value: <samp>Type mismatch</samp>.
* <code><var>offset</var></code> is not in the range `[-32768 to 65535]`: <samp>Overflow</samp>.
