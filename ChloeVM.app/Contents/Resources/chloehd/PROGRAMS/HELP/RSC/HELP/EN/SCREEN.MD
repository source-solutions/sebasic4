### SCREEN
***
<code><b>SCREEN</b> [<var>mode</var>] [<b>,</b> [<var>colorburst</var>] [<b>,</b> [<var>apage</var>] [<b>,</b> [<var>vpage</var>] [<b>,</b> <var>erase</var>]]]]</code>

Change the video mode, composite colorburst, active page and visible page. Video modes are described in the <a href="#videomodes">Video Modes</a> section.

#### Parameters
<code><var>mode</var></code> is a numeric expression that sets the screen mode.

Video mode | Notes
--- | ---
`0` | Text mode.</br>80x24 characters.</br>Two attributes picked from 16 colors.
`1` | Bitmap mode.</br>240 x 192 pixles.</br>40x24 characters of 6x8 pixels.</br>8x1 attributes from 16 colors.

#### Notes
The driver for `SCREEN 1` is stored in RAM and can be replaced with a driver for any screen mode supported by the hardware. 

#### Errors
* No parameters are specified: <samp>Missing operand</samp>.
* Any parameter has a string value: <samp>Type mismatch</samp>.
* Any parameter is not in `[-32768 to 32767]`: <samp>Overflow</samp>.
* <code><var>mode</var></code> is not an available video mode number for your video card setting: <samp>Illegal function call</samp>.
