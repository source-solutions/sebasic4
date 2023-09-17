### INPUT
***
<code><b>INPUT</b> [<b>;</b>] [<var>prompt</var> {<b>;</b>|<b>,</b>}] <var>var_0</var> [<b>,</b> <var>var_1</var>] ... </code>

Prints <code><var>prompt</var></code> to the screen and waits for the user to input values for the
specified variables. The semicolon before the prompt, if present, stops a
newline from being printed after the values have been entered. If the prompt is followed by a semicolon, it is printed with a trailing <code>?</code>. If the prompt is
followed by a comma, no question mark is added.

#### Parameters
* <code><var>prompt</var></code> is a string literal.
* <code><var>var_0</var>, <var>var_1</var>, ...</code> are variable names or fully indexed array elements.

#### Notes
* Values entered must be separated by commas. Leading and trailing whitespace is  discarded.
* String values can be entered with or without double quotes (`"`).
* If a string with a comma, leading or trailing whitespace is needed, quotes are  the only way to enter it.
* Between a closing quote and the comma at the end of the entry, only white-
  space is allowed.
* If quotes are needed in the string itself, the first character must be neither  a quote nor whitespace. It is not possible to enter a string that starts with   a quote through `INPUT`.
* If a given <code><var>var_n</var></code> is a numeric variable, the value entered must be number
  literal.
* Characters beyond the 255th character of the screen line are discarded.
* If user input is interrupted by <kbd>Ctrl</kbd>+<kbd>Break</kbd>, [`CONT`](CONT) will re-execute the `INPUT`
  statement.

#### Errors
* If the value entered for a numeric variable is not a valid numeric literal, or  the number of values entered does not match the number of variables in the
  statement, <samp>?Redo from start</samp> is printed and all values must be entered again.
* A <samp>Syntax error</samp> that is caused after the prompt is printed is only raised after  the value shave been entered. No values are stored.
