### COPY
***
<code>COPY <var>file_spec_1</var> <b>TO</b> <var>file_spec_2</var></code>

Copies the disk file <code><var>file_spec_1</var></code> to <code><var>file_spec_2</var></code>.

#### Parameters

The string expressions <code><var>file_spec_1</var></code> and <code><var>file_spec_2</var></code> are valid 
[`FILESPEC`](filespec) file-specifications indicating the source and destination files. The first
must point to an existing file on a disk device.

#### Notes
Typically, this command is not present in Microsoft BASIC.

#### Errors
* <code><var>file_spec_1</var></code> or <code><var>file_spec_2</var></code> have number values: <samp>Type mismatch</samp>
* <code><var>file_spec_1</var></code> does not exist: <samp>File not found</samp>
