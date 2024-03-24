#### File access modes
***
The <var>chr</var> are as follows:

<var>chr</var> | Means  | Effect
--- | ------ | -----------------------------------------------------------------
`"I"` | input  | Opens text file for reading and positions file pointer at start.
`"O"` | output | Truncates a text file at the start and opens it for writing.
`"A"` | append | Opens a text file for writing at the end of any existing data.
`"R"` | random | Opens a file for random access.

A single character can be read with <code>c$=INKEY$ #<var>file_num</var></code> or written with
<code>PRINT #<var>file_num</var>;c$;</code>. Strings are terminated with a carriage return. A string can
be read with <code>INPUT #<var>file_num</var>;s$</code> or written with <code>PRINT #<var>file_num</var>;s$</code>.

##### Warning
When opening a file for output (`"O"`), any data previously present in the file
will be deleted.
