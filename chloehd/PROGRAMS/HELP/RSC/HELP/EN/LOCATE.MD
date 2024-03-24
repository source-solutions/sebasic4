### LOCATE
***
<code><b>LOCATE</b>[<var>row</var>]<b>,</b> [<var>col</var>]</code>

Set the next print position to <code><var>row</var></code>, <code><var>col</var></code> on the screen. 

#### Notes
In Microsoft BASIC, the cursor can be displayed or made invisible and its shape can be changed. This is not supported in SE Basic IV.

#### Errors
* Any parameter has a string value: <samp>Type mismatch</samp>.
* Any parameter is not in `[-32768 to 32767]`: <samp>Overflow</samp>.
* <code><var>row</var></code> is outside the current view area: <samp>Illegal function call</samp>.
* <code><var>col</var></code> is greater than the current width: <samp>Illegal function call</samp>.

