### PRINT
***
<code><b>PRINT</b> [<b>#</b> <var>stream</var><b>,</b>] [<var>expr_0</var>|<b>;</b>|<b>,</b>|<b>SPC(</b> <var>n</var><b>)</b>|<b>TAB(</b> <var>n</var><b>)</b>] ... [<b>USING</b> <var>format</var><b>;</b> <var>uexpr_0</var> [{<b>;</b>|<b>,</b>} <var>uexpr_1</var>] ... [<b>;</b>|<b>,</b>]]</code>

Writes expressions to the screen, a file or another device. If <code><var>stream</var></code> is
specified, output goes to the file or device open under that number.
`?` is a shorthand for `PRINT`.

When writing a string expression to the screen, the following control characters
have special meaning. Other characters are shown as their corresponding glyph in
the current [codepage](codepage).

Code | Chr | Effect
-----|-----|------------------------------------------------------------------
`$07`  | `BEL` | Beep the speaker.
`$08`  | `BS`  | Erase character in previous column and move cursor back.
`$09`  | `HT`  | Jump to the next 8-cell tab stop.
`$0A`  | `LF`  | Go to the leftmost column in the next row.
`$0B`  | `VT`  | Move the cursor to the top left of the screen.
`$0C`  | `FF`  | Clear the screen.
`$0D`  | `CR`  | Go to the leftmost column in the next row.
`$1C`  | `FS`  | Move the cursor one column to the right.
`$1D`  | `GS`  | Move the cursor one column to the left.
`$1E`  | `RS`  | Move the cursor one row up.
`$1F`  | `US`  | Move the cursor one row down.

<b>Note</b>: In SE BASIC, anything after `PRINT CHR$(12)` is not printed.

Expressions can optionally be separated by one or more keywords:

Keyword | Effect
--------|-----------------------------------------------------------
`;`       | Attaches two expressions without any space in between.
<code>SPC(<var>n</var>)</code>  | Produces <code><var>n</var></code> spaces, where <code><var>n</var></code> is a numeric expression.
`,`       | The expression after will be positioned at next available tab stop.
<code>TAB(<var>n</var>)</code>  | Moves to column <code><var>n</var></code>, where <code><var>n</var></code> is a numeric expression.
`'`       | Inserts a newline.

If the print statement does not end in one of these four separation tokens, a
newline is printed after the last expression. String expressions can be
separated by one or more spaces, which has the same effect as separating by
semicolons.
