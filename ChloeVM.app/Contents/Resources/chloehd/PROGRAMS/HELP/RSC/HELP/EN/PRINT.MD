### PRINT
***
<code><b>PRINT</b> [<b>#</b> <var>stream</var><b>,</b>] [<var>expr_0</var>|<b>;</b>|<b>,</b>|<b>SPC(</b> <var>n</var><b>)</b>|<b>TAB(</b> <var>n</var><b>)</b>] ... [<b>USING</b> <var>format</var><b>;</b> <var>uexpr_0</var> [{<b>;</b>|<b>,</b>} <var>uexpr_1</var>] ... [<b>;</b>|<b>,</b>]]</code>

Writes expressions to the screen, a file or another device. If <code><var>stream</var></code> is specified, output goes to the file or device open under that number. `?` is a shorthand for `PRINT`.

When writing a string expression to the screen, the following control characters have special meaning. Other characters are shown as their corresponding glyph in the current [codepage]().

Code point | Control character | Effect
--- | --- | ---
`$07` | _`BEL`_ | Beep the speaker.
`$08` | _`BS`_ | Erase the character in the previous column and move the cursor back.
`$09` | _`HT`_ | Jump to the next 8-cell tab stop.
`$0A` | _`LF`_ | Go to the leftmost column in the next row; connect the rows to one logical line.
`$0B` | _`VT`_ | Move the cursor to the top left of the screen.
`$0C` | _`FF`_ | Clear the screen.
`$0D` | _`CR`_ | Go to the leftmost column in the next row.
`$1C` | _`FS`_ | Move the cursor one column to the right.
`$1D` | _`GS`_ | Move the cursor one column to the left.
`$1E` | _`RS`_ | Move the cursor one row up.
`$1F` | _`US`_ | Move the cursor one row down.

__Note__: In SE Basic IV, anything after `PRINT CHR$(12)` is not printed.

Expressions can optionally be separated by one or more of the following keywords:

Keyword | Effect
--- | ---
`;` | Attaches two expressions tight together; strings will be printed without any space in between, numbers will have one space separating them, in addition to the space or minus sign that indicate the sign of the number.
`,` | The expression after will be positioned at the next available tab stop.
`'` | Inserts a newline.
<code>SPC(<var>n</var>)</code> | Produces _`n`_ spaces, where _`n`_ is a numeric expression. If _`n`_ is less than zero, it defaults to zero. If _`n`_ is greater than the file width, it is taken modulo the file width.
<code>TAB(<var>n</var>)</code> | Moves to column _`n`_, where _`n`_ is a numeric expression. if _`n`_ is less than zero, it defaults to zero. If _`n`_ is greater than the file width, it is taken modulo the file width. If the current column is greater than _`n`_, `TAB` moves to column _`n`_ on the next line.

If the print statement does not end in one of these four separation tokens, a newline is printed after the last expression. String expressions can be separated by one or more spaces, which has the same effect as separating by semicolons.
