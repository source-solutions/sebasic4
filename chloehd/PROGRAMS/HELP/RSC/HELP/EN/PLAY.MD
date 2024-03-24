### PLAY
***
<code><b>PLAY</b> <var>mml_string_1</var><b>[,</b> <var>mml_string_2</var>[, ... <var>mml_string_8<var>]</code>

Plays the tune defined by the Music Macro Language ([MML](MML)) strings <code><var>mml_string_1</var>, ...</code>.

### Example
```
10 a$ = "h1t100o2[[[1CCg-b]][[-E-E-b-D]][[FFC-E]][[GGDF]]]]"
20 b$ = "h2o5rrrrC-bfG]"
30 c$ = "h3o4[[3Cr]Cr1CCDD[3-Er]-Er1-E-EEE[3Fr]Fr1FF-G-G[3Gr]Gr1GG-EC]]"
40 d$ = "h4l9rrrrrrrr[9EGF7b5CD]]"
50 PLAY a$, b$, c$, d$
```
#### Parameters
* <code><var>mml_string_1</var>...<var>mml_string_8</var></code> are string expressions in MML.
* At least one parameter must be provided and the statement must not end in a comma.

#### Errors
* <var>mml_string</var> has a numeric value: <samp>Type mismatch</samp>.
* <var>mml_string</var> has errors in the MML: <samp>Syntax error</samp>.

