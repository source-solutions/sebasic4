;	// LASTV8 - An example of 6 channel audio.
; 	//			Using the Arkos Tracker 2 AKY TurboSound player.
;	// Copyright (c) 2020 Source Solutions, Inc.

;	// system headers
	include "../../../SYSTEM/HEADERS/SYSTEM.INC"

;	// constants
	print_a equ $10;					// print a character
	chan_open equ $1601;				// channel open

	org $6000

;	// print intro text
	xor a;								// LD A, 0 (system screen)
	call SEScreenMode;					// API: set screen mode (also does CLS)

	ld ix, text;						// point to text
	call SEScreenPrintString;			// API: print ASCIIZ string

	ld ix, text_lo;						// point to text
	call SEScreenLowerPrintString;		// API: print ASCIIZ string (lower screen)

pr_key:
	call SEKeyboardWaitKey;						// wait for a keypress
	cp ' ';								// space?
	jr nz, pr_key;						// loop if not

;	// original start

setup:
	ld a, 4;							// border color
	out ($fe), a;						// set it
	ld a, %00011111;					// video 1, ROM 1, RAM 7
	ld bc, $7ffd;						// 128 paging
	out (c), a;							// set it
	ld a, %00000010;					// 8x1 attribute mode
	out ($ff), a;						// set it (SCLD)

ld_title_scr:
	ld ix, screen;						// ASCIIZ filename
	call open;							// open file

	ld ix, $c000;						// offset 0 in frame buffer
	ld bc, 6144;						// byte count
	call load;							// load the 1st half of file

	ld ix, $e000;						// offset 1 in frame buffer
	ld bc, 6208;						// byte count
	call load;							// load the 2nd half of the file + palette

	call close;							// close file

	ld ix, $f83f - 63;					// first byte of palette
	call SEGraphicsPaletteSet;					// API: set 64 palette registers

load_player:
	ld ix, player;						// ASCIIZ filename
	call open;							// open file

	ld ix, $8181;						// IM2 address
	ld bc, 4837;						// byte count
	call load;							// load the player

	call close;							// close file

	jp $8183;							// jump to player

;	// subroutines
open:
	call SEFileOpenExists;				// open file
	ld (handle), a;						// store file handle
	ret;								// done

load:
	ld a, (handle);						// file handle
	jp SEFileRead;						// exit via read file vector

close:
	ld a, (handle);						// file handle
	call SEFileClose;					// close file
	ret;								// done

;	// data
screen:
	defb "LASTV8.SCR", 0;				// title screen filename

player;
	defb "LASTV8.BIN", 0;				// music player and data

handle;
	defb 0;								// file handle

text:
	defb "The Last V8 - version 1.3", 13;
 	defb "Copyright (C) 1985 Rob Hubbard", 13;
	defb 13;
	defb '"', "The Last V8", '"', " was published by Mastertronic in 1985 on its M.A.D. label. It was", 13;
	defb "released on the C64, C128, Atari 8-bit and Amstrad CPC. It was designed and", 13;
	defb "programmed by brothers Ricahrd and David Darling who later founded Codemasters.", 13;
	defb "Graphics were by Jim Wilson, but the most memorable part is Rob Hubbard's music.", 13;
	defb 13;
	defb "The title is derived from a plot point in the ", '"', "Mad Max", '"', " series of films. Set in", 13;
	defb "a dystopian 2008, the world is devastated by nuclear war with few survivors.", 13;
	defb "Surviving for years in an underground bunker, the protagonist has built a V8-", 13;
	defb "engined car with radiation shield capable of 250mph out of a 1980s vehicle.", 13;
	defb 13;
	defb "Unless you play the C128 version; in which case you start on a colony on Mars.", 13;
	defb "Either way, you have to drive around Earth looking for survivors of the war.", 13;
	defb "While on the surface you must avoid crashing, running out of fuel and radiation.", 13;
	defb "If a nuclear missile explodes, a digitized voice tells you to return to base.", 13;
	defb 13;
	defb "Although by all accounts the game is pretty terrible to play, the graphics were", 13;
	defb "praised by reviewers. But the music is consistently in the top 20 of all time", 13;
	defb "best SID tunes lists on the C64 where Rob Hubbard usually accounts for a quarter", 13;
	defb "of all the entries. This 6-channel version is included with Arkos Tracker II.", 13;
	defb 0;

text_lo:
	defb "NOW PRESS SPACE TO START THE DEMO", 0;
