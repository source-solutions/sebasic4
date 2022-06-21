### READ
***
<code><b>READ</b> <var>var_0</var> [<b>,</b> <var>var_1</var>] ... </code>

Assigns data from a [](#DATA">DATA</a></code> statement to variables. Reading starts at the current <code>DATA</code> position, which is the <code>DATA</code> entry immediately after the last one read by previous <code>READ</code> statements. The <code>DATA</code> position is reset to the start by the [](#RUN">RUN</a></code> and [](#RESTORE">RESTORE</a></code> statements.

#### Parameters
<code><var>var_0</var></code>, <code><var>var_1</var></code> are variables or array elements.

#### Errors
* Not enough data is present in <code>DATA</code> statements: <samp>Out of DATA</samp>.
* The type of the variable is not compatible with that of the data entry being read: a <samp>Syntax error</samp> occurs on the <code>DATA</code> line.
