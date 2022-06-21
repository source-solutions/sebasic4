### FILES
***
<code><b>FILES</b> [<var>filter_spec</var>]</code>

Displays the files fitting the specified filter in the specified folder on a disk device. If <code><var>filter_spec</var></code> is not specified, displays all files in the current working folder.

#### Parameters
* <code><var>filter_spec</var></code> is a string expression that is much like a [file specification](#file-specification), but optionally allows the file name part to contain <dfn>wildcards</dfn>.

#### Notes
Wildcards are not currently supported.

#### Errors
* <code><var>filter_spec</var></code> has a numeric value: <samp>Type mismatch</samp>.
* <code><var>filter_spec</var></code> is the empty string: <samp>Bad file name</samp>.
* The specified filter does not match any files: <samp>File not found</samp>.
