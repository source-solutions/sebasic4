### IF
***
<code><b>IF</b> <var>truth_value</var>  {<b>THEN</b>|<b>GOTO</b>} [<var>compound_statement_true</var>|<var>line_number_true</var> [<var>anything</var>]] [<b>ELSE</b> [<var>compound_statement_false</var>|<var>line_number_false</var> [<var>anything</var>]]]
   </code>

If <code><var>truth_value</var></code> is non-zero, executes <code><var>compound_statement_true</var></code> or jumps to <code><var>line_number_true</var></code> . If it is zero, executes <code><var>compound_statement_false</var></code> or jumps to <code><var>line_number_false</var></code> .

#### Parameters
* <code><var>truth_value</var></code> is a numeric expression.
* <code><var>line_number_false</var></code> and <code><var>line_number_true</var></code> are existing line numbers.
* <code><var>compound_statement_false</var></code> and <code><var>compound_statement_true</var></code> are compound statements, consisting of at least one statement, optionally followed by further statements separated by colons <code>:</code>. The compound statements may contain nested <code>IF to THEN to ELSE</code> statements.

#### Notes
* The comma is optional and ignored.
* [ELSE](#ELSE) clauses are optional; they are bound to the innermost free `IF` statement if nested. Additional `ELSE` clauses that have no matching `IF` are ignored.
* All clauses must be on the same program line.
* `THEN` and `GOTO` are interchangeable; which one is chosen is independent of whether a statement or a line number is given. `GOTO PRINT 1`</code>` is fine.
* As in [GOTO](#GOTO), anything after the line number is ignored.

#### Errors
* If <code><var>truth_value</var></code> has a string value: <samp>Type mismatch</samp>.
* <code><var>truth_value</var></code> equals <code>0</code> and <code><var>line_number_false</var></code> is a non-existing line number, or <code><var>truth_value</var></code> is nonzero and <code><var>line_number_true</var></code> is a non-existing line number: <samp>Undefined line number</samp>.
