### CONT
***
<code><b>CONT</b></code>

Resumes execution of a program that has been halted by [`STOP`](#STOP), [`END`](#END) or <kbd>Esc</kbd>.

#### Notes
* Anything after the `CONT` keyword is ignored.
* This statement can only be used in direct mode.
* If a break is encountered in [`GOSUB`](#GOSUB) routine called from a continuing direct
  line (for example, `GOSUB 100:PRINT A$`), `CONT` will overwrite the running direct  line. As the subroutine [`RETURN`](#RETURN)s to the position after the `GOSUB` in the old
  direct line, strange things may happen if commands are given after `CONT`. In
  Microsoft BASIC, this can lead to strange errors in non-existing program lines
  as the parser executes bytes that are not part of a program line. In SE Basic
  IV, if the new direct line is shorter, execution stops after `RETURN`; but if
  the direct line is extended beyond the old return position, the parser tries
  to resume at that return position, with strange effects.

#### Errors
* No program is loaded, a program has not been run, after a program line has
  been modified or after [`CLEAR`](#CLEAR): <samp>Can't continue</samp>.
* The break occurred in a direct line: <samp>Can't continue</samp>.
* `CONT` is used in a program: <samp>Can't continue</samp>.
