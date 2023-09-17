### SCREEN
***
<code><b>SCREEN</b> [<var>mode</var>] [<b>,</b> [<var>colorburst</var>] [<b>,</b> [<var>apage</var>] [<b>,</b> [<var>vpage</var>] [<b>,</b> <var>erase</var>]]]]</code>

Change the video mode, composite colorburst, active page and visible page.

#### Parameters
<code><var>mode</var></code> is a numeric expression that sets the screen mode.

Mode | Notes
-----|--------------------------------------------------------------------------
 `0`   | Text: 80x24 characters. Two attributes picked from 16 colors.
 `1`   | Bitmap: 240x192 pixels. 40x24 characters. 8x1 attributes from 16 colors.

#### Notes
The driver for `SCREEN 1` is stored in RAM and can be replaced with a driver for
any screen mode supported by the hardware. 

#### Errors
* No parameters are specified: <samp>Missing operand</samp>.
* Any parameter has a string value: <samp>Type mismatch</samp>.
* Any parameter is not in `[-32768 to 32767]`: <samp>Overflow</samp>.
* <code><var>mode</var></code> is not an available video mode number for your video card setting:
  <samp>Illegal function call</samp>.
