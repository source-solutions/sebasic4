;	// SKYFALL - An example of 6 channel audio.
; 	//			 Using the Arkos Tracker 2 AKY TurboSound player.
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
	ld a, 1;							// border color
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

 	ld ix, $f83f -63;					// last byte of palette
	call SEGraphicsPaletteSet;					// API: set 64 palette registers

ram_pag:
	ld a, %00011000;					// video 1, ROM 1, RAM 0
	ld bc, $7ffd;						// 128 paging
	out (c), a;							// set it

load_player:
	ld ix, player;						// ASCIIZ filename
	call open;							// open file

	ld ix, $8181;						// IM2 address
	ld bc, 10408;						// byte count (FIXME - get file size) 
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
	jp SEFileClose;						// exit via close file vecto

;	// data
screen:
	defb "SKYFALL.SCR", 0;				// title screen filename

player;
	defb "SKYFALL.BIN", 0;				// music player and data

handle;
	defb 0;								// file handle

text:
	defb "Skyfall - version 1.2", 13;
 	defb "Copyright (C) 2012 Adele Adkins & Paul Epworth", 13;
	defb 13;
	defb "The boot chime of the Chloe 280SE is Cm9, a variation on the James Bond chord.", 13;
	defb "Sony Pictures President of Music Lia Vollack suggested to Eon Productions that", 13;
	defb "they ask Adele to record the theme song for Bond 23 because her voice had a", 13;
	defb '"', "soulful, haunting, evocative quality", '"', " and ", '"', "classic Shirley Bassey feel", '"', ".", 13;
	defb 13;
	defb "Paul Epworth who had produced her second studio album ", '"', "21", '"', " was brought in to co-", 13;
	defb "write. Although the first draft was written in 10 minutes, the process toook 18", 13;
	defb "months to complete, culminating in two studio sessions at Abbey Road Studios in", 13;
	defb "London with a 77-piece orchestra conducted by J.A.C. Redford.", 13;
	defb 13;
	defb "The song intentionally references Monty Norman's ", '"', "James Bond Theme", '"', " after the", 13;
	defb "first chorus and his leitmotif for the character was included with his approval.", 13;
	defb "A slew of awards followed, including an Oscar, a Grammy and a Golden Globe.", 13;
	defb "Like the Chloe, the film is modern but harks back to a past that never existed.", 13;
	defb 13;
	defb "This demo was the fist make use of the Chloe's MIDI to PSG workflow. It starts", 13;
	defb "with a MIDI file of the full arrangement. This is reduced to six tracks with one", 13;
	defb "note polyphony per track in Aria Maestosa. This version of the MIDI file is then", 13;
	defb "imported into Arkos Tracker II. The player code comes from ", '"', "The Last V8", '"', " demo.", 13;
	defb 0;

text_lo:
	defb "NOW PRESS SPACE TO START THE DEMO", 0;
