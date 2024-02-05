;	// Snowfall - An example of color cycling animation,
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
	ld h, %11111111;					// white

main_loop:

; transition to frame 2
	halt;								// wait for vblank
	halt;								// wait for vblank
	halt;								// wait for vblank
	halt;								// wait for vblank
	halt;								// wait for vblank
	halt;								// wait for vblank
	halt;								// wait for vblank
	halt;								// wait for vblank


	ld a, 2;							// register 2
	ld l, 0;							// black
	call set_both;						// set reg and next to white

	ld a, 5;							// register 5
	ld l, 1;							// blue 1
	call set_both;						// set reg and next to white

	ld a, 10;							// register 10
	ld l, 2;							// blue 2
	call set_both;						// set reg and next to white

	ld a, 13;							// register 13
	ld l, 3;							// blue 3
	call set_both;						// set reg and next to white

	ld a, 18;							// register 18
	ld l, %00001111;					// g0 r3 b3
	call set_both;						// set reg and next to white

	ld a, 21;							// register 21
	ld l, %00010111;					// g0 r5 b3
	call set_both;						// set reg and next to white

	ld a, 26;							// register 26
	ld l, %00111111;					// g0 r7 b3
	call set_both;						// set reg and next to white

	ld a, 29;							// register 29
	ld l, %01111111;					// g3 r7 b3
	call set_both;						// set reg and next to white

; transition to frame 3
	halt;								// wait for vblank
	halt;								// wait for vblank
	halt;								// wait for vblank
	halt;								// wait for vblank
	halt;								// wait for vblank
	halt;								// wait for vblank
	halt;								// wait for vblank
	halt;								// wait for vblank
	halt;								// wait for vblank
	halt;								// wait for vblank


	ld a, 3;							// register 3
	ld l, 0;							// black
	call set_both;						// set reg and next to white

	ld a, 6;							// register 6
	ld l, 1;							// blue 1
	call set_both;						// set reg and next to white

	ld a, 11;							// register 11
	ld l, 2;							// blue 2
	call set_both;						// set reg and next to white

	ld a, 14;							// register 14
	ld l, 3;							// blue 3
	call set_both;						// set reg and next to white

	ld a, 19;							// register 19
	ld l, %00001111;					// g0 r3 b3
	call set_both;						// set reg and next to white

	ld a, 22;							// register 22
	ld l, %00010111;					// g0 r5 b3
	call set_both;						// set reg and next to white

	ld a, 27;							// register 27
	ld l, %00111111;					// g0 r7 b3
	call set_both;						// set reg and next to white

	ld a, 30;							// register 30
	ld l, %01111111;					// g3 r7 b3
	call set_both;						// set reg and next to white

; transition to frame 1
	halt;								// wait for vblank
	halt;								// wait for vblank
	halt;								// wait for vblank
	halt;								// wait for vblank
	halt;								// wait for vblank
	halt;								// wait for vblank
	halt;								// wait for vblank
	halt;								// wait for vblank
	halt;								// wait for vblank
	halt;								// wait for vblank


	ld a, 4;							// register 4
	ld l, 0;							// black
	call set_last;						// set reg and first to white

	ld a, 7;							// register 7
	ld l, 1;							// blue 1
	call set_last;						// set reg and first to white

	ld a, 12;							// register 12
	ld l, 2;							// blue 2
	call set_last;						// set reg and first to white

	ld a, 15;							// register 15
	ld l, 3;							// blue 3
	call set_last;						// set reg and first to white

	ld a, 20;							// register 20
	ld l, %00001111;					// g0 r3 b3
	call set_last;						// set reg and first to white

	ld a, 23;							// register 23
	ld l, %00010111;					// g0 r5 b3
	call set_last;						// set reg and first to white

	ld a, 28;							// register 28
	ld l, %0011111;						// g0 r7 b3
	call set_last;						// set reg and first to white

	ld a, 31;							// register 31
	ld l, %01111111;					// g3 r7 b3
	call set_last;						// set reg and first to white

; loop
	jp main_loop;						// infinite loop

set_last;
	call set_reg;						// call set_reg
	dec a;								// back two registers
	dec a;								//
	ld l, h;							// white
	jr set_reg;							// set it

set_both:
	call set_reg;						// call set_reg

set_next_white:
	inc a;								// register 3
	ld l, h;							// white

set_reg:
	ld b, e;							// register port
	out (c), a;							// select register
	ld b, d;							// data port
	out (c), l;							// set color in L
	ret;								// done

;---

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
	defb "SNOWFALL.SCR", 0;				// title screen filename

;player;
;	defb "LASTV8.BIN", 0;				// music player and data

handle;
	defb 0;								// file handle

text:
	defb "Snowfall - version 1.3", 13;
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
