### RUN
***
<code><b>RUN</b> [<var>line_number</var> | <var>app_name</var> [, <var>p0</var>, <var>p1</var>, ...]]</code>

Executes a program. Existing variables will be cleared and any program in memory will be erased. <code>RUN</code> implies a [CLEAR](#CLEAR). If an <code><var>app_name</var></code> is specified, opens the application. 

#### Parameters
* <code><var>line_number</var></code> is a valid line number in the current program. If specified, execution starts from this line number. The rest of the <code>RUN</code> statement is ignored in this case.
* The string expression <code><var>app_name</var></code>, if specified, is a valid application name (case-insensitive, truncated to the first 11 characters).
* <code><var>p0</var>, <var>p1</var>, ...</code> are variables.

#### Errors
* <code><var>line_number</var></code> is not a line number in the current program: <samp>Undefined line number</samp>.
* <code><var>app_name</var></code> cannot be found: <samp>File not found</samp>.
