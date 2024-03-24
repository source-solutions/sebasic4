### RENUM
***
<code><b>RENUM</b> [<var>new</var>|<b>.</b>] [<b>,</b> [<var>old</var>|<b>.</b>] [<b>,</b> <var>increment</var>]]</code>

Replaces the line numbers in the program by a systematic enumeration starting
from <code><var>new</var></code> and increasing by <code><var>increment</var></code>. If <code><var>old</var></code> is specified, line numbers less
than <code><var>old</var></code> remain unchanged. <code><var>new</var></code>, <code><var>old</var></code> are line numbers; the dot <code>.</code> signifies the
last line edited. <code><var>increment</var></code> is a line number but must not be a dot or zero.

#### Notes
The following keywords can reference line numbers, which will be renumbered by
`RENUM`: [`GOSUB`](GOSUB), [`GOTO`](GOTO), [`LIST`](LIST), [`RESTORE`](RESTORE), [`RUN`](RUN).

#### Errors
* Any of the parameters is not in `[0 to 65529]`: <samp>Syntax error</samp>.
* Any of the newly generated line numbers is greater than `65529`: <samp>Illegal          function call</samp>. The line numbers up to the error have not been changed.
* <code><var>increment</var></code> is empty or zero: <samp>Illegal function call</samp>.
* <code><var>old</var></code> is specified and <code><var>new</var></code> is less than or equal to an existing line number less  than old: <samp>Illegal function call</samp>.
