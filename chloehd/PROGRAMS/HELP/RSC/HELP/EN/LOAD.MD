### LOAD
***
<code><b>LOAD</b> <var>file_spec</var> [<b>,{"R"|"T"}</b>]</code>

Loads the program stored in a file into memory. Existing variables will be cleared and any program in memory will be erased. `LOAD` implies a `[CLEAR](CLEAR)`.

If `,"R"` is specified, keeps all data files open and runs the specified file.
If `,"T"` is specified, loads a tokenized program.

#### Parameters
The string expression <var>file_spec</var> is a valid [filespec](FILESPEC) indicating the
file to read the program from.

#### Notes
* Unlike Microsoft BASIC, SE Basic IV always expects BASIC programs to be in
  plain text format.
* Unlike Microsoft BASIC, the `R` directive must be in quotes. Otherwise SE Basic 
  IV would treat it as a variable.

#### Errors
* <code><var>file_spec</var></code> has a numeric value: <samp>Type mismatch</samp>.
* <code><var>file_spec</var></code> contains disallowed characters: <samp>Bad file name</samp>.
* The file specified in <code><var>file_spec</var></code> cannot be found: <samp>File not found</samp>.
* A loaded text file contains lines without line numbers: <samp>Direct statement in     file</samp>.
