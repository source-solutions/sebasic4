### KEY (macro definition)
***
<code><b>KEY</b> <var>key_id</var>, <var>string_value</var></code>

Defines the string macro for functino key `key_id`. Only the first 15 characters of `string_value` are stored.

#### Parameters
* `key_id` is a numeric expression in the range `[1 to 15]`.
* `string value` is a string expression.

#### Notes
* If `key_id` is not in the prescribed range, an error is raised.
* If `string_value` is the empty string or the first character of `string_value` is `CHR$(0)`, the function key macro is switched off and subsequent catching of the associated function key with [INKEY$](#INKEY$) is enabled.

#### Errors
* `key_id` is not in `[-32768 to 32767]`: <sample>Overflow</sample>.
* `key_id` is not in `[1 to 255]`: <sample>Illegal function call</sample>.
* `key_id` has a string value: <sample>Type mismatch</sample>.


### KEY (macro list)
***
<code><b>KEY LIST</b></code>

Prints a list of the 15 function keys with the functino-key macros defined for those keys to the console.

Most characters are represented by their symbol equivalent in the current [codepage](#codepage). However, some characters get a different represenation, which is a symbolic representation of the effect as control characters on the screen.

Code point | Replacement | Usual glyph
---|---|---
`$07` | `$0E` | ♫
`$08` | `$FE` | ■
`$09` | `$1A` | →
`$0A` | `$1B` | ←
`$0B` | `$7F` | ⌂
`$0C` | `$16` | ▬
`$0D` | `$1B` | ←
`$1C` | `$10` | ►
`$1D` | `$11` | ◄
`$1E` | `$18` | ↑
`$1F` | `$19` | ↓

### KEY (macro toggle)
***
<code><b>KEY</b> {<b>ON</b>|<b>OFF</b>}</b></code>

Toggles function-key macros `ON` or `OFF`.

### KILL
***
<code><b>KILL</b> <var>file_spec</var></code>

Deletes a file on a disk device.

#### Parameters
The string expression <code><var>file_spec</var></code> is a valid [file specification](#file-specification) indicating the file to delete. It must point to an existing file on a disk device.

#### Errors
* <code><var>file_spec</var></code> has a number value: <samp>Type mismatch</samp>.
* The file <code><var>file_spec</var></code> is open: <samp>File already open</samp>
* The file or path <code><var>file_spec</var></code> does not exist: <samp>File not found</samp>
* The user has no write permission: <samp>Permission denied</samp>
* If a syntax error occurs after the closing quote, the file is removed anyway.
