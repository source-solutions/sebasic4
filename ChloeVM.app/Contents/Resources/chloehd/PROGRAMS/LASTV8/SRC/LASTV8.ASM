;	// LASTV8 - An example of 6 channel audio.
; 	//			Using the Arkos Tracker 2 AKY TurboSound player.
;	// Copyright (c) 2020 Source Solutions, Inc.

;	// OS hook codes
	include "UNODOS3.INC"

	org $6000

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

set_palette:
	ld hl, $f83f;						// last byte of palette
	ld c, $3b;							// palette port
	ld de, $00bf;						// d = data, e = register
	ld a, 64;							// becomes 63
	halt;								// wait for vblank

palette_loop:
	dec a;								// next register
	ld b, e;							// register port
	out (c), a;							// select register
	ld b, d;							// data port
	outd;								// dec b; out bc, (hl); dec hl
	and a;								// was that the last register?
	jr nz, palette_loop;				// set all 64 entries

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
	ld a, '*';							// use current drive
	ld b, fa_read | fa_open_ex;			// open for reading if file exists
	rst divmmc;							// issue a hookcode
	defb f_open;						// open file
	ld (handle), a;						// store file handle
	ret;								// done

load:
	ld a, (handle);						// file handle
	rst divmmc;							// issue a hookcode
	defb f_read;						// read bytes
	ret;								// end of subroutine

close:
	ld a, (handle);						// file handle
	rst divmmc;							// issue a hookcode
	defb f_close;						// close file
	ret;								// done

;	// data
screen:
	defb "LASTV8.SCR", 0;				// title screen filename

player;
	defb "LASTV8.BIN", 0;				// music player and data

handle;
	defb 0;								// file handle
