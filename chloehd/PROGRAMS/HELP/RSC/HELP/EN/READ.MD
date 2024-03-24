### READ
***
<code><b>READ</b> <var>var_0</var> [<b>,</b> <var>var_1</var>] ... </code>

Assigns data from a [`DATA`](DATA) statement to variables. Reading starts at the current
`DATA` position, which is the `DATA` entry immediately after the last one read by
previous `READ` statements. The `DATA` position is reset to the start by the [`RUN`](RUN)
and [`RESTORE`](RESTORE) statements.

#### Parameters
<code><var>var_0</var></code>, <code><var>var_1</var></code> are variables or array elements.

#### Errors
* Not enough data is present in `DATA` statements: <samp>Out of DATA</samp>.
* The type of the variable is not compatible with that of the data entry being
  read: a <samp>Syntax error</samp> occurs on the `DATA` line.
