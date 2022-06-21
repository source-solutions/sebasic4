### RND
***
<code><var>random</var> <b>= RND</b>[<b>(</b><var>x</var><b>)</b>]</code>

Returns a pseudorandom number in the interval `0 to 1)</code>.

#### Parameters
<code><var>x</var></code> is a numeric expression.
* If <code><var>x</var></code> is zero, `RND` repeats the last pseudo-random number.
* If <code><var>x</var></code> is greater than zero, a new pseudorandom number is returned.
* If <code><var>x</var></code> is negative, <code><var>x</var></code> is converted to a single-precision floating-point value and the random number seed is set to the absolute value of its mantissa. The function then generates a new pseudorandom numer with this seed. Since the only the mantissa of <code><var>x</var></code> is used, any two values whose ratio is a power of 2 will produce the same seed. Note that this procedure for generating a new seed differs from that used by [RANDOMIZE](#RANDOMIZE).

#### Notes
* SE Basic IV's `RND` function produces different random numbers from Microsoft BASIC.
* It is a very poor random number generator. `RND` should not be used for cryptography, scientific simulations or anything else remotely serious.

#### Errors
* <code><var>x</var></code> has a string value: <samp>Type mismatch</samp>.
