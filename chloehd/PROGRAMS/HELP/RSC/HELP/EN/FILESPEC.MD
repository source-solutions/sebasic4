#### File specification
***
<code><var>file_spec</var></code> is a non-empty string expression of the form <code><b>"</b><var>parameters</var><b>"</b></code>. 

<code><var>parameters</var></code> must specify a valid file path of the form <code>[<b>/</b>][<var>dirname</var><b>/</b>]...<var>filename</var></code>.

In SE BASIC, file support is provided using the disk opertaing system (DOS).
UnoDOS 3 follows MS-DOS file system conventions with the exception that folder
names are separated with forward slashes (`/`). SE BASIC adds syntactic sugar
to the short filename format. File names consist of an 8-character name and
3-character extension. Folder names consist of an 11-character name. Permissible
characters are the printable ASCII characters in the range `[$20 to $7E]`
excluding the characters <code>" \* + . , / : ; < = > ? \ [ ] |</code>. Spaces are allowed but are converted to underscores. 

A path starting with a forward slash is interpreted as an absolute path,
starting at the root of the specified disk device. Otherwise, the path is
interpreted as relative to the current folder on the specified device. The
special folder name <code><b>..</b></code> refers to the parent folder of a preceding path, or the
parent folder of the current folder if no path is given. The special folder name
<code><b>.</b></code> refers to the same folder as given by the preceding path, or the current
folder if no preceding path is given.