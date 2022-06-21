### MKDIR
***
<code><b>MKDIR</b> <var>dir_spec</var></code>

Creates a new folder on a disk device.

#### Parameters
The string expression <code><var>dir_spec</var></code> is a valid [file specification](#file-specification) that specifies the path of the new folder on a disk device.

#### Errors
* <code><var>dir_spec</var></code> is not a string: <samp>Type mismatch</samp>.
* The parent folder does not exist: <samp>Path not found</samp>.
* The folder name already exists on that path: <samp>Path/File access error</samp>.
* The user has no write permission: <samp>Permission denied</samp>.
