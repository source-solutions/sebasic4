### CLS
***
<code><b>CLS</b> [<var>x</var>]</code>

Clears the screen or part of it. If <code><var>x</var></code> is not specified, in SCREEN 0 the text view region is cleared; in other screens, the graphics view region is cleared. The comma is optional and has no effect.

#### Parameters
<code><var>x</var></code> is a numeric valued expression that determines what is cleared:
* If <code><var>x</var> = 0</code>, the whole screen is cleared.
* If <code><var>x</var> = 1</code>, the graphics view region is cleared.
* If <code><var>x</var> = 2</code>, the text view region is cleared.

#### Errors
* <code><var>x</var></code> is has a string value: <samp>Type mismatch</samp>.
* <code><var>x</var></code> is not in `[-32768 to 32767]`: <samp>Overflow</samp> .
* <code><var>x</var></code> is not in `[0, 1, 2]`: <samp>Illegal function call</samp>.
* If an error occurs, the screen is not cleared.
