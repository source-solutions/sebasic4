# ZXZVM for Chloe

A port of John Elliott's ZXZVM Z-machine interpreter to the Chloe computer system.

## About

ZXZVM is a Z-machine interpreter that can run Infocom text adventure games and modern Interactive Fiction written for the Z-machine virtual machine. This port allows these games to run on the Chloe system.

## Building

```bash
make
```

This will create the `PRG/ZXZVM` executable.

## Installation

Copy the `PRG/ZXZVM` file to your Chloe's `/PROGRAMS/ZXZVM/PRG/` directory.

## Usage

1. Copy your Z-machine game files (.z3, .z5, .z8, etc.) to the `/PROGRAMS/ZXZVM/RSC/` directory.

2. Run from BASIC:
   ```basic
   RUN "ZXZVM"
   ```

3. When prompted, enter the name of the Z-machine file you want to run (with or without the .z5 extension).

## Supported Formats

- Z-machine versions 3, 5, and 8 (most Infocom games)
- Standard Z-machine games in .z3, .z5, .z8 format

## Example Games

Popular Z-machine games that should work include:
- Zork I, II, III
- Hitchhiker's Guide to the Galaxy  
- Planetfall
- Many modern Interactive Fiction games

## Technical Notes

This port uses:
- Chloe's native filesystem (UnoDOS 3) for file I/O
- Standard Chloe screen mode 0 output (80x24 text display)
- Chloe keyboard input handling
- Memory layout optimized for Chloe's architecture

## Limitations

Current limitations in this initial port:
- Save/restore functionality may not work with all games
- Some advanced Z-machine features may not be fully implemented
- Graphics and sound are not supported

## Credits

- Original ZXZVM by John Elliott
- Chloe port by Source Solutions, Inc.
- Based on ZXZVM version distributed with the original source

## License

This software is released under the GNU General Public License, same as the original ZXZVM.