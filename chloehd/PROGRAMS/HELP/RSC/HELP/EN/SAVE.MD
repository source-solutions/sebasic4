### SAVE
***
<code><b>SAVE</b> <var>file_spec</var> [<b>,"T"</b>]</code>

Stores the current program in a file.

If `,"T"` is specified, saves a tokenized program.

#### Parameters
The string expression <code><var>file_spec</var></code> is a valid [filespec](FILESPEC) indicating the
file to store to.

#### Notes
In Microsofr BASIC you can append `, A` to save the file in plain text or `, P` to
save a protected listing, otherwise the file is saved in tokenized format. In SE
BASIC the file is saved in plain text format unless you append `, "T"`.

#### Errors
* <code><var>file_spec</var></code> has a number value: <samp>Type mismatch</samp>.
* <code><var>file_spec</var></code> is an empty string: <samp>Bad I/O device</samp>.
* <code><var>file_spec</var></code> is too long: <samp>Bad I/O device</samp>.
