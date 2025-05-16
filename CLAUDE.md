# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SE BASIC is a BASIC interpreter for the Z80 architecture. It's designed to run on the Chloe 280SE hardware platform but is also compatible with Timex Sinclair models with 128K of RAM, esxDOS, Timex video modes, and ULAplus. The project is written in Z80 assembly language and organized into modular components.

## Build Requirements

The following tools are required to build the project:
- Java
- JQ (JSON processor)
- Perl
- RASM (Z80 assembler)

## Build Commands

### Linux
```bash
./scripts/build-linux.sh
```

### macOS
```bash
./scripts/build-mac.sh
```

### Windows
```
scripts\build.cmd
```

## Run Commands

### Linux
```bash
./scripts/run-linux.sh
```

### macOS
```bash
./scripts/run-mac.sh
```

### Windows
```
scripts\run.cmd
```

## Emulator Setup

- **Linux**: Fuse is the recommended emulator
- **macOS/Windows**: ZEsarUX is the recommended emulator

For Fuse builds, uncomment the `slam` directives in `basic.asm` and `boot.asm`.

## Project Architecture

The project is structured into modules that handle different aspects of the BASIC interpreter:

1. **Boot ROM**: Located in `/boot/boot.asm` - handles system startup
2. **BASIC ROM**: Located in `/basic/basic.asm` - main BASIC interpreter code

The BASIC interpreter is divided into modules:
- Restarts
- Tokenizer
- Keyboard handling
- SE-OS (operating system interface)
- Preprocessor
- Screen routines
- Editor
- Executive (command processor)
- Expression evaluation
- Arithmetic operations
- Calculator functionality
- Data handling
- File operations
- Audio functionality
- System messages

## Documentation

The project includes extensive documentation:
- Quick start guide
- User's guide
- Configuration guide
- Language guide
- Language reference
- Technical reference

These documents are available in the project wiki at https://github.com/source-solutions/sebasic4/wiki/