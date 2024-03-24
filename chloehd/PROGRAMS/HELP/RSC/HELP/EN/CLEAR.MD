### CLEAR
***
<code><b>CLEAR</b> [<var>mem_limit</var>]</code>

Clears all variables, arrays, [`DEF FN`](DEF-FN) user functions. Closes all files. Turns
off all sound. Clears all [`ON ERROR`](ON-ERROR) traps. Clears the loop stack.

#### Parameters
<code><var>mem_limit</var></code> specifies the upper limit of usable memory. Default is previous memory
size. Default memory size is 65535.

#### Notes
If called inside a [`FOR`](FOR) to [`NEXT`](NEXT) or [`WHILE`](WHILE) to [`WEND`](WEND) loop, an error will be 
raised at the `NEXT` or `WEND` statement, since the loop stacks have been cleared.

#### Errors
* Any of the arguments has a string value: <samp>Type mismatch</samp>.
* <code><var>mem_limit</var></code> is not in `[0 to 65535]`: <samp>Overflow</samp>.
* <code><var>mem_limit</var></code> is too low: <samp>Address out of range</samp>.
