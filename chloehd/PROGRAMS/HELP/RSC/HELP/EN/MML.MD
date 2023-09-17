### Music Macro Language
***
The [`PLAY`](PLAY) command in SE Basic IV uses a version of Music Macro Language (MML). Other than note names (`c`, `d`, `e`, `f`, `g`, `a`, `b`), instructions are case-insensitive. Upper case notes (`C`, `D`, `E`, `F`, `G`, `A`, `B`) are one octave higher than the current octave. Phrases in square brackets ( `[`, `]` ) are played twice. Brackets can be nested up to four levels. A closing bracket without a matching opening bracket loops the preceding phrase indefinitely. Comments can be enclosed between single quote marks ( `'` ). The other instructions are:

* `r` is a rest.
* `-` before a note flattens it.
* `+` or `#` before a note sharpens it.
* `&` indicates tied notes.
* `o` sets the octave (`1` to `8`).
* `l` sets the note length (`0` to `9`) as classic MML, or triplets (`10` to `12`).
* `t` sets the tempo in beats per minute (BPM) (`32` to `255`).
* `v` sets the volume (`0 to `15`) and switches off envelopes on that channel.
* `s` sets the [ENVELOPE](ENVELOPE) waveform (`0` to `15`) and activates it.
* `m` sets the modulation frequency (`1` to `65536`).
* `h` sets the MIDI channel (`1` to `16`).
* `z` sends a command (`0` to `255`) to the MIDI port.
* `x` exits the `PLAY` command immediately.
* `>` increases the octave by one.
* `<` decreases the octave by one

The defaults are:

* note length: quarter note
* octave: 4
* tempo: 120
* volume: 15
