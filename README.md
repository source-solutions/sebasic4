# SE Basic IV 4.2 Cordelia

This repository contains the firmware source code, compiled binaries and documentation for the Chloe 280SE microcomputer.

## Build prerequisites

The preferred IDE is _Visual Studio Code_ (https://code.visualstudio.com/) with Maziac's _Z80 Debugger_ extension (install from the app).

The compiler is the _Zeus Command Line_ assembler.

The emulator is _ZEsarUX_.

### Linux

* Install _Wine_: `sudo apt-get install wine`
* Build the emulator: https://github.com/chernandezba/zesarux
* Modify the `task.json` file in the `.vscode` folder to 

### macOS (not Catalina)

1. Install _HomeBrew_ (https://brew.sh/):

   `/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

2. After _HomeBrew_ is installed, install _Wine_:

   `brew install wine`

### Windows

1. Create a subfolder called `perl`in the `asmdoc` folder.
2. Install the portable version of Strawberry Perl: http://strawberryperl.com/releases.html.

### iOS

It is not possible to build on iOS but it is possible to edit the source with _Textastic_ and manage the repository with _Working Copy_.
You can add Z80 syntax highlighting to _Textastic_ by using a _Sublime 3_ [plugin](https://github.com/psbhlw/sublime-text-z80asm) and [copying](https://www.textasticapp.com/v7/manual/managing_files/local_files_icloud.html) it to a folder called  `#Textastic` in  `Local Files`.

## Components

The firmware comprises:

* __BOOT__: A small program that initializes the hardware and copies the font and parts of the BASIC and DOS programs to the required locations in memory.
* __BASIC__: A 23K program containing the BIOS and an interpreter for the BASIC language.
* __OS__: A 16K program that provides an interface between the BIOS and MMC media.

## Binary structure

The binaries are contained in three ROM files:

* __0__: First 8K of OS.
* __1__: Bootstrap, second 8K of OS and last 7K of BASIC.
* __2__: First 16K of BASIC.

## Boot sequence

From a cold start:

* ROM-__0__ is selected.
  1. Initialization of OS commences.
  2. Second half of OS is copied from ROM-1 to OS-RAM.
  3. OS jumps to start of ROM-2, where code ensures that:
* ROM-__1__ is selected.
  1. All RAM is cleared.
  2. All audio is muted.
  3. Initial palette is set.
  4. The font is copied to the frame buffer.
  5. The last 7K of BASIC is copied to HOME-RAM, then:
* ROM-__2__ is selected.
  1. BASIC system variables and editor are initialized.
  2. Copyright message is displayed and the user is prompted for input.

## User environment

The firmware presents the user with a command line interface to the BASIC language interpreter. The syntax is very similar to MS-BASIC. File commands are provided directly from BASIC and there is no separate OS shell. The OS is contained entirely in the firmware and does not require any additional files to be loaded from disk. After the system is initialized, the BASIC ROM is paged out only when calls are made to the OS. BASIC supports two video modes: 40 columns with 16 colors or 80 columns with two colors.

## License

Copyright &copy; 1999-2020 Source Solutions, Inc. All rights reserved.

Licensed under the [GNU General Public License](LICENSE).
