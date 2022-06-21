### KEY (macro definition)
***
<code><b>KEY</b> <var>key_id</var>, <var>string_value</var></code>

Defines the string macro for function key `key_id`. Only the first 15 characters
of `string_value` are stored.

#### Parameters
* `key_id` is a numeric expression in the range `[1 to 15]`.
* `string value` is a string expression.

#### Notes
* If `key_id` is not in the prescribed range, an error is raised.
* If `string_value` is the empty string or the first character of `string_value` is
  `CHR$(0)`, the function key macro is switched off and subsequent catching of the  associated function key with [`INKEY$`](#INKEY$) is enabled.

#### Errors
* `key_id` is not in `[-32768 to 32767]`: <samp>Overflow</samp>.
* `key_id` is not in `[1 to 255]`: <samp>Illegal function call</samp>.
* `key_id` has a string value: <samp>Type mismatch</samp>.

### KEY (macro list)
***
<code><b>KEY LIST</b></code>

Prints a list of the 15 function keys with the function-key macros defined for
those keys to the console.

Most characters are represented by their symbol equivalent in the current
[codepage](#codepage). However, some characters get a different representation, which is a symbolic representation of the effect as control characters on the screen.


### KEY (macro toggle)
***
<code><b>KEY</b> {<b>ON</b>|<b>OFF</b>}</b></code>

Toggles function-key macros `ON` or `OFF`.




