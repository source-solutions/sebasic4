### RND
***
<code><var>random</var> <b>= RND</b>[<b>(</b><var>x</var><b>)</b>]</code>

Returns a pseudorandom number.

#### Parameters
<code><var>x</var></code> is a numeric expression. This value is ignored.

#### Notes
* SE BASIC's `RND` function produces different random numbers from 
  Microsoft BASIC.
* It is a very poor random number generator. `RND` should not be used for 
  cryptography, scientific simulations or anything else remotely serious.

#### Errors
<code><var>x</var></code> has a string value: <samp>Type mismatch</samp>.
