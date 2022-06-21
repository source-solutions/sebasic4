### NEXT
***
<code><b>NEXT</b> [<var>var_0</var> [<b>,</b> <var>var_1</var>] ...]</code>

Iterates a <code>FOR to NEXT</code> loop: increments the loop variable and jumps to the [](#FOR">FOR</a></code> statement. If no variables are specified, next matches the most recent <code>FOR</code> statement. Several nested <code>NEXT</code> statements can be consolidated into one by using the variable list. If one or more variables are specified, their order must match the order of earlier <code>FOR</code> statements.

#### Parameters
<code><var>var_0</var>, <var>var_1</var>, ...</code> are numeric variables which are loop counters in a <code>FOR</code> statement.

#### Errors
* No <code>FOR</code> statement is found to match the <code>NEXT</code> statement and variables: <samp>NEXT without FOR</samp>.
* <code><var>var_0</var>, <var>var_1</var>, ...</code> are string variables: <samp>NEXT without FOR</samp>.
* The (implicit or explicit) loop variable is an integer variable and is taken outside the range `[-32768, 32767]` when incremented after the final iteration: <samp>Overflow</samp>.
