### PALETTE
***
<code><b>PALETTE</b> [<var>attrib</var><b>,</b> <var>color</var>]</code>

Assigns a colour to an attribute. All pixels with that attribute will change colour immediately. If no parameters are specified, <code>PALETTE</code> resets to the initial setting.

#### Parameters
* <code><var>attrib</var></code> is a numeric expression from `[0 to 63]`.
* <code><var>color</var></code> is a numeric expression between `[0 and 255]`

#### Notes
Colors are entered in compressed RGB format (lowest to highest bit). The red and green levels are each stored in three bits (`0 to 7`) while the blue level is stored in two bits (`0 to 3`). The easiest way to enter values is in octal (`@BGR`). For example, to set <code><var>attribute</var></code> to maximum blue, you would enter <code>PALETTE <var>attribute</var>, @300</code>.

#### Errors
* <code><var>attrib</var></code> or <code><var>colour</var></code> has a string value: <samp>Type mismatch</samp>.
* <code><var>attrib</var></code> or <code><var>colour</var></code> is not in `[ to 32767]`: <samp>Overflow</samp>
* <code><var>attrib</var></code> or <code><var>colour</var></code> is not in range: <samp>Illegal function call</samp>
