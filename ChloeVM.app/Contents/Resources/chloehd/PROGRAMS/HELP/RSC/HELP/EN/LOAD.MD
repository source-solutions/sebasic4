### LOAD
***
<code><b>LOAD</b> <var>file_spec</var> [<b>,{"R"|"T"}</b>]</code>

Loads the program stored in a file into memory. Existing variables will be cleared and any program in memory will be erased. `LOAD` implies a `[CLEAR](#CLEAR)`.

If `,"R"` is specified, keeps all data files open and runs the specified file.
If `,"T"` is specified, loads a tokenized program.

#### Parameters
The string expression <code><var>file_spec</var></code> is a valid [file specification](#file-specification) indicating the file to read the program from.

#### Notes
* Unlike Microsoft BASIC, SE Basic IV always expects BASIC programs to be in plain text format.
* Unlike Microsoft BASIC, the `R` directive must be in quotes. Otherwise SE Basic IV would treat it as a variable.

#### Errors
* <code><var>file_spec</var></code> has a numeric value: <samp>Type mismatch</samp>.
* <code><var>file_spec</var></code> contains disallowed characters: <samp>Bad file number</samp> (on <code>CAS1:</code>); <samp>Bad file name</samp> (on disk devices).
* The file specified in <code><var>file_spec</var></code> cannot be found: <samp>File not found</samp>.
* A loaded text file contains lines without line numbers: <samp>Direct statement in file</samp>.
* A loaded text file contains lines longer than 255 characters: <samp>Line buffer overflow</samp>. Attempting to load a text file that has <code><i>LF</i></code> rather than <code><i>CR LF</i></code> line endings may cause this error.
