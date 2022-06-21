### OPEN
***
<code><b>OPEN #</b> <var>file_num</var>, "<var>mode_char</var>" [,<var>file_spec</var>]</code>

Opens a data file on a device.

#### Parameters
* The string expression <var>file_spec</var> is a valid [file specification](#file-specification).
* <var>file_num</var> is a valid stream `[3 to 15]`.
* <var>mode_char</var> is a string expression of which the first character is one of:
  * `["K", "S"]` - system channel (keyboard or screen).
  * `["I", "O", "A", "R"] - [access mode](#access-modes) for a disk file.
  * other alpha character - a used defined channel.

#### Access modes

The <var>mode_char</var> are as follows:

<var>mode_char</var> | Meaning | Effect
--- | --- | ---
"I" | INPUT | Opens a text file for reading and positions the file pointer at the start.
"O" | OUTPUT | Truncates a text file at the start and opens it for writing. Any data previously present in the file will be deleted.
"A" | APPEND | Opens a text file for writing at the end of any existing data.
"R" | RANDOM | Opens a file for random access.

A single character can be read with <code>c$=INKEY$ #<var>file_num</var></code> or written with <code>PRINT #<var>file_num</var>;c$;</code>. Strings are terminated with a carriage return. A string can be read with <code>INPUT #<var>file_num</var>;s$</code> or written with <code>PRINT #<var>file_num</var>;s$</code>.

#### File specification
<code><var>file_spec</var></code> is a non-empty string expression of the form <code><b>"</b><var>parameters</var><b>"</b></code>. 

<code><var>parameters</var></code> must specify a valid file path of the form <code>[<b>/</b>][<var>dirname</var><b>/</b>] ... <var>filename</var></code>. 

In SE Basic IV, file support is provided using the OS kernel. UnoDOS 3 follows MS-DOS file system conventions with the exception that folder names are separated with forward slashes (`/`). SE Basic IV adds syntactic sugar to the short filename format. File names consist of an 8-character name and 3-character extension. Folder names consist of an 11-character name. Permissible characters are the printable ASCII characters in the range `[$20 to $7E]` excluding the characters <code>" * + . , / : ; < = > ? \ [ ] |</code>. Spaces are allowed but are converted to underscores. 

A path starting with a forward slash is interpreted as an absolute path, starting at the root of the specified disk device. Otherwise, the path is interpreted as relative to the current folder on the specified device. The special folder name <code><b>..</b></code> refers to the parent folder of a preceding path, or the parent folder of the current folder if no path is given. The special folder name <code><b>.</b></code> refers to the same folder as given by the preceding path, or the current folder if no preceding path is given. 

The [LOAD](#LOAD) and [SAVE](#SAVE) statements do not currently implicitly add a default extension `.BAS` if no extension is specified..

#### Compatibility notes 

UnoDOS 3 allows certain characters in the range `$7F to $FF`. However, their permissibility and interpretation depends on the console code page, which may be different from the display code page currently in use. Therefore you should avoid using these characters.

#### Errors

* <var>file_num</var> is a non-existent stream: <samp>Undefined stream</samp>.
* <var>file_num</var> is not in range `[0 to 15]`: <samp>Bad I/O device</samp>.
* <var>mode_char</var> is a non-existent channel: <samp>Undefined channel</samp>.
* <var>file_spec</var> is non-existent in input or append mode: <samp>File not found</samp>.
