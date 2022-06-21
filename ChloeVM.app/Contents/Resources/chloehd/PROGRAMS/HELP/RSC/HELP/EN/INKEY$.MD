### INKEY$
***
<code><var>key</var> <b>= INKEY$</b> [ #<var>file_num</var>]</code>

Returns one character from the stream <var>file_num</var>. If no stream is specified, returns one key-press from the keyboard buffer. If the keyboard buffer is empty, returns the empty string. Otherwise, the return value is a one-character string holding the [e-ASCII]() code of the pressed key.

#### Notes
When a function key <kbd>F1</kbd> to <kbd>F15</kbd> is pressed, `INKEY$` will return the letters of the associated macro unless it's been set to empty with the [KEY](#KEY) statement, in which case it returns the e-ASCII code for the function key.
