### COLOR
***
<code><b>COLOR</b> [<var>foreground</var>] [<b>,</b> [<var>background</var>] [<b>,</b> <var>border</var>]]</code>

Changes the current foreground and background attributes. All new characters printed will take the newly set attributes. Existing characters on the screen are not affected.

#### Parameters
* <code><var>foreground</var></code> is a numeric expression in `[0 to 15]`. This specifies the new foreground attribute.
* <code><var>background</var></code> is a numeric expression in `0 to 15`. This specifies the new background attribute.
* <code><var>border</var></code> is a numeric expression in `[0 to 15]` specifying the border attribute.  It is taken `MOD 8`: Values `8 to 15` produce the same colour as `0 to 7`.

#### Errors
* Any of the parameters has a string value: <samp>Type mismatch</samp>.
* Any of the parameters is not in `[-32768 to 32767]`: <samp>Overflow</samp>.
* <code><var>foreground</var></code> is not in `[0 to 31]`, <code><var>background</var></code> is not in `[0 to 15]` or <code><var>border</var></code> is not in `[0 to 15]`: <samp>Illegal function call</samp>.
* Statement is used in <code>SCREEN 2</code>: <samp>Illegal function call</samp>.
