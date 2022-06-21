### LET
***
<code>[<b>LET</b>] <var>name</var> <b>=</b> <var>expression</var></code>

Assigns the value of <code><var>expression</var></code> to the variable or array element <code><var>name</var></code>.

#### Parameters
* <code><var>name</var></code> is a variable that may or may not already exist.
* The type of <code><var>expression</var></code> matches that of <code><var>name</var></code>: that is, all numeric types can be  assigned to each other but strings can only be assigned to strings.

#### Errors
<code><var>name</var></code> and <code><var>expression</var></code> are not of matching types: <samp>Type mismatch</samp>.
