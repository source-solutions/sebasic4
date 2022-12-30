### Overview
***
This quick start guide covers installation and elementary use of SE Basic IV.
For more information refer to the [SE Basic IV documentation](Home).

If you find bugs, [open an issue on GitHub](https://github.com/source-solutions/sebasic4/issues). It would be most helpful if you
could include a short but of BASIC code that triggers the bug.

## Installation
SE Basic IV is available as a 32K ROM file (`se.rom`) or a firmware update
(`firmwa~1.bin`) for the [Chloe 280SE](Chloe-280SE).

To update your Chloe 280SE, copy the firmware update to the root of your SD card
and power cycle the computer.

SE Basic IV is provided with the [Chloe virtual machine](https://sourcesolutions.itch.io/chloevm) for macOS and Windows. You can update to the latest version by replacing the 32K ROM file in the
package.

If you are using SE Basic IV with a Sinclair ZX Spectrum, you must flash the 32K
ROM file onto a 32K EEPROM.

## User environment
SE Basic IV presents you with a command line interface to the BASIC language
interpreter. The syntax is very similar to Microsoft BASIC. File commands are
provided directly from BASIC and there is no separate OS shell. The OS is
contained entirely in the firmware and does not require any additional files to
be loaded from disk. After the system is initialized, the BASIC ROM is paged out
only when calls are made to the OS. BASIC supports two video modes: 80 columns
with two colors or 40 columns with 16 colors.

## BASIC survival kit
SE Basic IV has a 1980s-style interface operated by executing typed commands. There is no menu, nor are there any of the visual clues that we've come to expect of modern software.

A few essential commands to help you get around:

Command            | Effect
-------------------|------------------------------------------------------------
`LOAD "PROGRAM.BAS"` | Loads the program file named `PROGRAM.BAS` into memory.
`LIST`               | Displays the BASIC code of the current program.
`RUN`                | Starts the current program.
`RUN "APPLICATION"`  | Opens an installed application named `APPLICATION`.
`SAVE "PROGRAM.BAS"` | Saves the current program to a file named `PROGRAM.BAS`.
`NEW`                | Immediately deletes the current program from memory.
`OLD`                | Restore the program to memory deleted by the last `NEW`. 

Use <kbd>F0</kbd> (NMI) or <kbd>ESC</kbd> to interrupt a running program.

## Program location
On real hardware, SE Basic IV looks for programs in the current folder.

* On Windows, this is `ChloeVM.app\\Contents\\Resources\\chloehd\\`
* On macOS, right click the <b>ChloeVM</b> application and select <b>Show Package Contents</b>
  and navigate to `/Contents/Resources/chloehd/`.

## External resources
See the [collection of Microsoft BASIC programs and tutorials](https://github.com/robhagemans/hoard-of-gwbasic).
