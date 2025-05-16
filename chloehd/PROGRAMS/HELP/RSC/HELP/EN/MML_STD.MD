# Standard Music Macro Language (MML)

The `PLAY` command in SE BASIC now uses the standard Music Macro Language (MML) syntax, which is compatible with the MML implementation used in many other systems.

## Notes and Rests

* Notes: `c`, `d`, `e`, `f`, `g`, `a`, `b` (lowercase for current octave)
* Notes: `C`, `D`, `E`, `F`, `G`, `A`, `B` (uppercase for one octave higher)
* Rest: `r`

## Accidentals (after the note)

* Sharp: `#` or `+` (e.g., `c#` or `c+`)
* Flat: `-` (e.g., `b-`)

## Length

* Default note length: `l1`-`l9` (1=whole note, 2=half note, 3=triplet half note, etc.)
* Note-specific length: `c4` (quarter note), `d8` (eighth note), etc.
* Dotted notes: `c.` or `c4.` (adds 50% to the duration)

## Octave

* Set octave: `o1`-`o8`
* Raise octave: `>`
* Lower octave: `<`

## Other Controls

* Tempo (BPM): `t32`-`t255` (default: 120)
* Volume: `v0`-`v15` (default: 15)
* Envelope: `s0`-`s15` (sets waveform and activates it)
* Tied notes: `&` (connects notes, e.g., `c&c#` is C tied to C#)
* Repeat: `[...]` phrases in brackets are played twice
* Comments: `'comment'` (between single quotes)
* MIDI channel: `h1`-`h16`
* MIDI command: `z0`-`z255`
* Exit: `x` (exits PLAY immediately)

## Examples

```basic
10 PLAY "t120 o4 l4 cdef gab>c"                  ' C major scale, quarter notes
20 PLAY "t100 o3 c8c8g8g8a8a8g4 f8f8e8e8d8d8c4"  ' Twinkle Twinkle Little Star
30 PLAY "o4 c.d8e.f8g4"                          ' Using dotted notes
40 PLAY "c4 r4 d4 r4 e4 r4"                      ' Notes with rests
50 PLAY "[cde]"                                   ' Plays "cdecde" (repeated once)
60 PLAY "c&c"                                     ' Tied notes
```

## Differences from Classic MML

The standard MML implementation has these key differences from SE BASIC's classic MML:

1. Accidentals (# and -) come AFTER the note, not before
2. Note lengths can be specified after each note
3. Dotted notes are supported using a dot (.)

For example, the classic MML `PLAY "+c"` would now be written as `PLAY "c#"` in standard MML.