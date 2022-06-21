### DIM
***
<code><b>DIM</b> <var>name</var> {<b>(</b>|<b>[</b>} <var>limit_0</var> [<b>,</b> <var>limit_1</var>] ... {<b>)</b>|<b>]</b>}</code>

Allocates memory for arrays. The `DIM` statement also fixes the number of indices of the array. An array can only be allocated once; to re-allocate an array, [ERASE](#ERASE) or [CLEAR](#CLEAR) must be executed first. If an array is first used without a `DIM` statement, it is automatically allocated with its maximum indices set at `10` for each index position used. If an array's `DIM` statement specifies no indices, it is allocated with a single index with maximum `10`. The least index allowed is determined by [OPTION BASE](#OPTION-BASE).

#### Parameters
* <code><var>name</var></code> is a legal variable name specifying the array to be allocated.
* <code><var>limit_0</var>, <var>limit_1</var>, ...</code> are numeric expressions that specify the greatest index allowed at that position.

#### Notes
* Mixed brackets are allowed.
* The size of arrays is limited by the available BASIC memory.
* The maximum number of indices is, theoretically, <code>255</code>. In practice, it is limited by the 255-byte limit on the length of program lines.

#### Errors
* <code><var>name</var></code> has already been dimensioned: <samp>Duplicate definition</samp>.
* An index is empty: <samp>Syntax error</samp>.
* An index is missing at the end: <samp>Missing operand</samp>.
* <code><var>limit_0</var>, <var>limit_1</var>, ...</code> have a string value: <samp>Type mismatch</samp>.
* <code><var>limit_0</var>, <var>limit_1</var>, ...</code> are not within `[-32768 to 32767]`: <samp>Overflow</samp>.
* <code><var>limit_0</var>, <var>limit_1</var>, ...</code> are negative: <samp>Illegal function call</samp>.
* The array exceeds the size of available variable space: <samp>Out of memory</samp>.
