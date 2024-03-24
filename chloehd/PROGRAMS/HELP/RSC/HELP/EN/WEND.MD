### WEND
***
<code><b>WEND</b></code>

Iterates a `WHILE-WEND` loop: jumps to the matching [`WHILE`](WHILE) statement, where its
condition can be checked.

#### Notes
`WHILE-WEND` loops can be nested. `WEND` jumps to the most recent `WHILE` statement
that has not been closed by another `WEND`.

#### Errors
All previous `WHILE` statements have been closed by another `WEND` or no `WHILE`
statement has been executed before: <samp>WEND without WHILE.</samp>
