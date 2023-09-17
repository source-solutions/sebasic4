# Quick start guide
***
SE BASIC presents you with a command line interface to the BASIC language
interpreter. The syntax is very similar to Microsoft BASIC. File commands are
provided directly from BASIC and there is no separate OS shell. A minimal
version of the OS is contained entirely in the firmware and does not require any
additional files to be loaded from disk. After the system is initialized, the
BASIC ROM is paged out only when calls are made to the disk operating system
(DOS). BASIC directly supports two video modes: 80 columns with two colors or 40
columns with 16 colors. Other modes can be loaded at runtime in place of the 40 column mode.

## Survival kit

SE BASIC has a 1980s-style interface operated by executing typed commands. There
is no menu, nor are there any of the visual clues that we've come to expect of
modern software. However, you can press the `HELP` key or enter `!HELP` to access
this wiki.












A few essential commands to help you get around:

Command            | Effect
------------------ | -----------------------------------------------------------
`LOAD "PROGRAM.BAS"` | Loads the program file named `PROGRAM.BAS` into memory.
`LIST`               | Displays the BASIC code of the current program.
`RUN`                | Starts the current program.
`RUN "APPLICATION"`  | Opens an installed application named `APPLICATION`.
`SAVE "PROGRAM.BAS"` | Saves the current program to a file named `PROGRAM.BAS`.
`NEW`                | Immediately deletes the current program from memory.
`OLD`                | Restore the program to memory deleted by the last `NEW`.
