### DIM
***
<code><b>DIM</b> <var>name</var> {<b>(</b>|<b>[</b>} <var>limit_0</var> [<b>,</b> <var>limit_1</var>] ... {<b>)</b>|<b>]</b>}</code>

Allocates memory for arrays. The `DIM` statement also fixes the number of indices of the array. Unlike Microsoft BASIC, an array can be reallocated.

#### Parameters
* <code><var>name</var></code> is a legal variable name specifying the array to be allocated.
* <code><var>limit_0</var>, <var>limit_1</var>, ...</code> are numeric expressions that specify the greatest index
  allowed at that position.

#### Notes
The size of arrays is limited by the available BASIC memory.

#### Errors
* An index is empty: <samp>Syntax error</samp>.
* An index is missing at the end: <samp>Missing operand</samp>.
* <code><var>limit_0</var>, <var>limit_1</var>, ...</code> have a string value: <samp>Type mismatch</samp>.
* <code><var>limit_0</var>, <var>limit_1</var>, ...</code> are not within `[-32768 to 32767]`: <samp>Overflow</samp>.
* <code><var>limit_0</var>, <var>limit_1</var>, ...</code> are negative: <samp>Illegal function call</samp>.
* The array exceeds the size of available variable space: <samp>Out of memory</samp>.
