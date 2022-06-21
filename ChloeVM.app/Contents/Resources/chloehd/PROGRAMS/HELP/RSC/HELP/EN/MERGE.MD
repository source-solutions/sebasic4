### MERGE
***
<code><b>MERGE</b> <var>file_spec</var></code>

Merges the program stored in a file into memory.

#### Parameters
The string expression <code><var>file_spec</var></code> is a valid [file specification](#file-specification) indicating the file to read the program from.

#### Notes
Unlike Microsoft BASIC, SE Basic IV always expects BASIC programs to be in plain text format.

#### Errors
* <code><var>file_spec</var></code> has a numeric value: <samp>Type mismatch</samp>.
* <code><var>file_spec</var></code> contains disallowed characters: <samp>Bad file number</samp> (on <code>CAS1:</code>); <samp>Bad file name</samp> (on disk devices).
* The file specified in <code><var>file_spec</var></code> cannot be found: <samp>File not found</samp>.
* A loaded text file contains lines without line numbers: <samp>Direct statement in file</samp>.
* A loaded text file contains lines longer than 255 characters: <samp>Line buffer overflow</samp>. Attempting to load a text file that has <code><i>LF</i></code> rather than <code><i>CR LF</i></code> line endings may cause this error.
