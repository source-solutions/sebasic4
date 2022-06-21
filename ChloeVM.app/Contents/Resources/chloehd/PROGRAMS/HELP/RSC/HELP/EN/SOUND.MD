### SOUND
***
<code><b>SOUND</b> <var>frequency</var><b>,</b> <var>duration</var> [<b>,</b> <var>volume</var> [<b>,</b> <var>voice</var>]]</code>

Produces a sound at <code><var>frequency</var></code> Hz for <code><var>duration</var>/18.2</code> seconds. On PCjr and Tandy, the volume and voice channel can additionally be specified.

If <code>PLAY "MB"</code> has been executed, <code>SOUND</code> plays in the background. If <code>PLAY "MF"</code> has been executed, sound plays in the foreground and the interpreter blocks until the sound is finished. Foreground mode is default. Unlike [](#PLAY">PLAY</a></code>, the sound played by the most recent <code>SOUND</code> statement always plays in the background, even if <code>PLAY "MF"</code> has been entered. In background mode, each <code>SOUND</code> statement counts as 1 toward the length of the queue reported by the [](#PLAY-function">PLAY</a></code> function.

#### Parameters
* <code><var>frequency</var></code> is a numeric expression in `[37 to 32767]` or `0` (for <code>syntax={advanced | pcjr}</code>) or in `[-32768 to 32767]` (for <code>syntax=tandy</code>).
* <code><var>duration</var></code> is a numeric expression in `[0 to 65535]`.
* <code><var>volume</var></code> is a numeric expression in [0, 15]. 0 is silent, 15 is full volume; every step less reduces the volume by 2 dB. (For <code>syntax={pcjr | tandy}</code>)
* <code><var>voice</var></code> is a numeric expression in [0, 2], indicating which of the three tone voice channels is used for this sound. (For [](#--syntax">syntax</a>={pcjr | tandy}</code>)

#### Notes
* If <code><var>duration</var></code> is zero, any active background sound is stopped and the sound queue is emptied.
* If <code><var>duration</var></code> is zero, <code><var>volume</var></code> and <code><var>voice</var></code> must not be specified.
* If <code><var>duration</var></code> is less than <code>.022</code> but nonzero, the sound will be played in background and continue indefinitely until another sound statement is executed. This is also the behaviour for negative <code><var>duration</var></code>.
* If <code><var>frequency</var></code> equals <code>32767</code> or <code>0</code>, a silence of length <code><var>duration</var></code> is queued.

#### Errors
* Any argument has a string value: <samp>Type mismatch</samp>.
* <code><var>frequency</var></code> is not in its allowed range, and <code><var>duration</var></code> is not zero: <samp>Illegal function call</samp>.
* <code><var>duration</var></code> is zero and more than two arguments are specified: <samp>Syntax error</samp>.
* [](#--syntax">syntax</a>={ pcjr | tandy }</code> is not set and more than two arguments are specified: <samp>Syntax error</samp>.
* <code><var>frequency</var></code> is not in `[-32768 to 32767]`: <samp>Overflow</samp>.
* <code><var>duration</var></code> is not in `[-65535 to 65535]`: <samp>Illegal function call</samp>.
* <code><var>volume</var></code> is not in `[0 to 15]`: <samp>Illegal function call</samp>.
* <code><var>voice</var></code> is not in `[0 to 2]`: <samp>Illegal function call</samp>.
