### CHDIR
***
<code><b>CHDIR</b> <var>dir_spec</var></code>

Change the current folder on a disk device to <code><var>dir_spec</var></code>. Each disk device has its own current folder.

#### Parameters
The string expression <code><var>dir_spec</var></code> is a valid [file specification](#file-specification) indicating an existing folder on a disk device.

#### Errors
* No matching path is found: <samp>Path not found</samp>.
* <code><var>dir_spec</var></code> has a numeric value: <samp>Type mismatch</samp>.
* <code><var>dir_spec</var></code> is empty: <samp>Bad file name</samp>.
