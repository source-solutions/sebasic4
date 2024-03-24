EOF
***
<code><var>is_at_end</var> <b>= EOF(</b><var>file_number</var><b>)</b></code>

Returns `-1` if file with number <var>file_number</var> has reached end-of-file; `0` otherwise.
The file must be open in INPUT or RANDOM mode. `EOF(0)` returns `0`.

#### Note
This is not yet implemented.
