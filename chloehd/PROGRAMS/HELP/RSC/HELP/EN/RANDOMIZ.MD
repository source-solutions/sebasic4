### RANDOMIZE
***
<code><b>RANDOMIZE</b> [<var>expr</var>]</code>

Seeds the random number generator with <code><var>expr</var></code>.

#### Parameters
<code><var>expr</var></code> is a numeric expression.

#### Notes
* For the same seed, SE BASIC produces different pseudorandom numbers from
  Microsoft BASIC.
* The random number generator is very poor and should not be used for serious
  purposes. See [`RND`](RND) for details.

#### Errors
* <code><var>expr</var></code> has a string value: <samp>Illegal function call</samp>.
* The user provides a seed outside `[-32768 to 32767]` at the prompt: <samp>Overflow</samp>.
