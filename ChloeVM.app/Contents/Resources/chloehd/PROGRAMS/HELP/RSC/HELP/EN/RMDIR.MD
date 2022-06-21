### RMDIR
***
<code><b>RMDIR</b> <var>dir_spec</var></code>

Removes an empty folder on a disk device.

#### Parameters
The string expression <code><var>dir_spec</var></code> is a valid [file specification](#file-specification) that specifies the path and name of the folder.

#### Errors
* <code><var>dir_spec</var></code> has a numeric value: <samp>Type mismatch</samp>.
* <code><var>dir_spec</var></code> is an empty string: <samp>Bad file name</samp> .
* No matching path is found: <samp>Path not found</samp> .
