;	// Beach of Rage - An example of multi-palette cycling,
;	// Copyright (c) 2024 Source Solutions, Inc.

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
	call SEKeyboardWaitKey;				// wait for a keypress
	cp ' ';								// space?
	jr nz, pr_key;						// loop if not

;	// original start

setup:
	ld a, 0;							// border color
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
	call SEGraphicsPaletteSet;			// API: set 64 palette registers

;load_player:
;	ld ix, player;						// ASCIIZ filename
;	call open;							// open file

;	ld ix, $8181;						// IM2 address
;	ld bc, 4837;						// byte count
;	call load;							// load the player

;	call close;							// close file

;	jp $8183;							// jump to player

main:
	ld c, $3b;							// palette port
	ld de, $ffbf;						// d = data, e = register

main_loop:
	call do_12;							// do 12 frames of rain
	call sea_out;						// do sea going out
	call do_12;							// do 12 frames of rain
	call sea_out;						// do sea going out
	call do_12;							// do 12 frames of rain
	call sea_out;						// do sea going out
	call do_12;							// do 12 frames of rain
	call sea_out;						// do sea going out
	call do_12;							// do 12 frames of rain

; wave return 1
	ld a, 9;							// first color
	ld l, %10101011;					// color 4
	ld b, e;							// register port
	out (c), a;							// select register
	ld b, d;							// data port
	out (c), l;							// replace with new color
	call do_12;							// do 12 frames of rain

; wave return 2
	ld a, 1;							// first color
	ld l, %10101011;					// color 4
	ld b, e;							// register port
	out (c), a;							// select register
	ld b, d;							// data port
	out (c), l;							// replace with new color

	ld a, 10;							// first color
	ld b, e;							// register port
	out (c), a;							// select register
	ld b, d;							// data port
	out (c), l;							// replace with new color

	ld a, 9;							// first color
	ld l, %00001011;					// color 3
	ld b, e;							// register port
	out (c), a;							// select register
	ld b, d;							// data port
	out (c), l;							// replace with new color
	call do_12;							// do 12 frames of rain

; wave return 3
	ld a, 2;							// first color
	ld l, %10101011;					// color 4
	ld b, e;							// register port
	out (c), a;							// select register
	ld b, d;							// data port
	out (c), l;							// replace with new color

	ld a, 11;							// first color
	ld b, e;							// register port
	out (c), a;							// select register
	ld b, d;							// data port
	out (c), l;							// replace with new color

	ld a, 1;							// first color
	ld l, %00001011;					// color 3
	ld b, e;							// register port
	out (c), a;							// select register
	ld b, d;							// data port
	out (c), l;							// replace with new color

	ld a, 10;							// first color
	ld b, e;							// register port
	out (c), a;							// select register
	ld b, d;							// data port
	out (c), l;							// replace with new color

	ld a, 9;							// first color
	ld l, %00000010;					// color 2
	ld b, e;							// register port
	out (c), a;							// select register
	ld b, d;							// data port
	out (c), l;							// replace with new color
	call do_12;							// do 12 frames of rain

; wave return 3
	ld a, 3;							// first color
	ld l, %10101011;					// color 4
	ld b, e;							// register port
	out (c), a;							// select register
	ld b, d;							// data port
	out (c), l;							// replace with new color

	ld a, 2;							// first color
	ld l, %00001011;					// color 3
	ld b, e;							// register port
	out (c), a;							// select register
	ld b, d;							// data port
	out (c), l;							// replace with new color

	ld a, 11;							// first color
	ld b, e;							// register port
	out (c), a;							// select register
	ld b, d;							// data port
	out (c), l;							// replace with new color

	ld a, 1;							// first color
	ld l, %00000010;					// color 2
	ld b, e;							// register port
	out (c), a;							// select register
	ld b, d;							// data port
	out (c), l;							// replace with new color

	ld a, 10;							// first color
	ld b, e;							// register port
	out (c), a;							// select register
	ld b, d;							// data port
	out (c), l;							// replace with new color

	ld a, 9;							// first color
	ld l, %00000001;					// color 1
	ld b, e;							// register port
	out (c), a;							// select register
	ld b, d;							// data port
	out (c), l;							// replace with new color
	jp main_loop;						// infinte loop

do_12:
	call cycle_rain;					// frame 1
	call cycle_rain;					// frame 2
	call cycle_rain;					// frame 3
	call cycle_rain;					// frame 4
	call cycle_rain;					// frame 5
	call cycle_rain;					// frame 6
	call cycle_rain;					// frame 7
	call cycle_rain;					// frame 8
	call cycle_rain;					// frame 9
	call cycle_rain;					// frame 10
	call cycle_rain;					// frame 11
	jp cycle_rain;						// frame 12

sea_out:
	ld h, %01101101;					// dark gray
	ld a, 3;							// color 4

	ld b, e;							// register port
	out (c), a;							// select register
	ld b, d;							// data port
	in l, (c);							// read color 4 to L
	out (c), h;							// replace with dark gray

	dec a;								// LD A, 2 - color 3

	ld b, e;							// register port
	out (c), a;							// select register
	ld b, d;							// data port
	in h, (c);							// read color 3 to H
	out (c), l;							// replace with color 4

	ld a, 11;							// do backgground color
	ld b, e;							// register port
	out (c), a;							// select register
	ld b, d;							// data port
	out (c), l;							// replace with color 4

	ld a, 1;							// color 2

	ld b, e;							// register port
	out (c), a;							// select register
	ld b, d;							// data port
	in l, (c);							// read color 2 to L
	out (c), h;							// replace with color 3

	ld a, 10;							// do background color
	ld b, e;							// register port
	out (c), a;							// select register
	ld b, d;							// data port
	out (c), h;							// replace with color 3

	ld a, 9;							// color 1

	ld b, e;							// register port
	out (c), a;							// select register
	ld b, d;							// data port
	out (c), l;							// replace with color 2
	ret;

cycle_rain:
	halt;								// wait for vblank
	ld a, 55;							// last rain palette entry

	ld b, e;							// register port
	out (c), a;							// select register

	ld b, d;							// data port
	in h, (c);							// read color to H
	ld a, 48;							// entry 0

	call cycle_one;						// do entry 0
	call cycle_one;						// do entry 1
	call cycle_one;						// do entry 2
	call cycle_one;						// do entry 3
	call cycle_one;						// do entry 4
	call cycle_one;						// do entry 5
	call cycle_one;						// do entry 6
;	call cycle_one;						// do entry 7
;	ret;

cycle_one:
	ld b, e;							// register port	
	out (c), a;							// select register
	ld b, d;							// data port
	in l, (c);							// read old color to L
	out (c), h;							// write new color from H
	ld h, l;							// old color to H
	inc a;								// next entry
	ret;

dopause:
	jp dopause;


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
	defb "BCHoRAGE.SCR", 0;				// title screen filename

;player;
;	defb "LASTV8.BIN", 0;				// music player and data

handle;
	defb 0;								// file handle

text:
	defb "BoR - version 1.3", 13;
 	defb "Copyright (C) 2024 Source Solutions, Inc.", 13;
	defb 13;
	defb "a", 13;
	defb "b", 13;
	defb "c", 13;
	defb "d", 13;
	defb 13;
	defb "e", 13;
	defb "f", 13;
	defb "g", 13;
	defb "h", 13;
	defb 13;
	defb "i", 13;
	defb "j", 13;
	defb "k", 13;
	defb "l", 13;
	defb 13;
	defb "m", 13;
	defb "n", 13;
	defb "o", 13;
	defb "p", 13;
	defb 0;

text_lo:
	defb "NOW PRESS SPACE TO START THE DEMO", 0;
