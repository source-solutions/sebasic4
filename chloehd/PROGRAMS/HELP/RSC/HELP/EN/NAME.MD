### NAME
***
<code><b>NAME</b> <var>old_name</var> <b>TO</b> <var>new_name</var></code>

Renames the disk file <code><var>old_name</var></code> into <code><var>new_name</var></code>.

#### Parameters
The string expressions <code><var>old_name</var></code> and <code><var>new_name</var></code> are valid [`FILESPEC`](filespec) file specifications giving the path on a disk device to the old and new filenames, respectively.

#### Notes
<code><var>new_name</var></code> will be modified into [all-uppercase 8.3 format](eightpointthree).

#### Errors
* <code><var>old_name</var></code> or <code><var>new_name</var></code> have number values: <samp>Type mismatch</samp>.
* <code><var>old_name</var></code> does not exist: <samp>File not found</samp>.
* <code><var>old_name</var></code> is open: <samp>File already open</samp>.
* <code><var>new_name</var></code> exists: <samp>File already exists</samp>.
