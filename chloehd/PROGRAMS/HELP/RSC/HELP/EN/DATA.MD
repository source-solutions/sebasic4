### DATA
***
<code><b>DATA</b> [<var>const_0</var>] [<b>,</b> [<var>const_1</var>]] ... </code>

Specifies data that can be read by a [`READ`](READ) statement.

#### Parameters
<code><var>const_0</var>, <var>const_1</var>, ...</code> are string and number literals or may be empty. String
literals can be given with or without quotation marks. If quotation marks are
omitted, leading and trailing whitespace is ignored and commas or colons will
terminate the data statement.

#### Errors
If the type of the literal does not match that of the corresponding [`READ`](READ)
statement, a <samp>Syntax error</samp> occurs on the `DATA` statement.
