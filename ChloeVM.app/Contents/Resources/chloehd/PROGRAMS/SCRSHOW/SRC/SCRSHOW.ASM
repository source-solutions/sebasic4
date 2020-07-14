;	// SCRSHOW - An example of how to recursively read files from a folder,
; 	//			 fade palettes in and out and use the frame counter.
;	// Copyright (c) 2019 Source Solutions, Inc.

;	// OS hook codes
	include "UNODOS3.INC"

	frame equ 23672;					// returns to zero every second
	org $6000

setup:
	xor a;								// LD A, 0;
	out ($fe), a;						// set default border
	ld a, %00011111;					// video 1, ROM 1, RAM 7
	ld bc, $7ffd;						// 128 paging
	out (c), a;							// set it
	ld a, %00000010;					// 8x1 attribute mode
	out ($ff), a;						// set it (SCLD)
	ld hl, fade_0 + 63;					// last entry @ 0% intensity
	call set_palette;					// make the screen black

read_files:
	ld b, 0;							// folder access mode (read only?)
	ld a, '*';							// use current drive
	ld ix, folder_path;					// folder path buffer
	rst divmmc;							// issue a hookcode
	defb f_opendir;						// open folder
	ld (handle_p), a;					// store path handle

read_files_2:
	ld ix, folder_entry;				// buffer
	ld a, (handle_p);					// get path handle
	rst divmmc;							// issue a hookcode
	defb f_readdir;						// read a folder entry
	or a;								// last entry?
	jp z, last_entry;					// jump if so
	ld hl, folder_entry;				// buffer
	ld a, (hl);							// attibutes to A
	and %00010000;						// folder?
	jr nz, read_files_2;				// skip folders

	ld ix, folder_entry + 1;			// ASCIIZ filename
	ld a, '*';							// use current drive
	ld b, fa_read | fa_open_ex;			// open for reading if file exists
	rst divmmc;							// issue a hookcode
	defb f_open;						// open file
	ld (handle_f), a;					// store file handle

	ld ix, $c000;						// offset 0 in frame buffer
	ld bc, 6144;						// byte count
	call load;							// load the 1st half of file

	ld ix, $e000;						// offset 1 in frame buffer
	ld bc, 6208;						// byte count
	call load;							// load the 2nd half of the file + palette

	ld a, (handle_f);					// file handle
	rst divmmc;							// issue a hookcode
	defb f_close;						// close file

	call fade;							// pre-fade the palette to black in 7 steps

	ld hl, fade_1 + 63;					// last entry @ 14% intensity
	call set_palette;					// set palette

	ld hl, fade_2 + 63;					// last entry @ 29% intensity
	call set_palette;					// set palette

	ld hl, fade_3 + 63;					// last entry @ 43% intensity
	call set_palette;					// set palette

	ld hl, fade_4 + 63;					// last entry @ 57% intensity
	call set_palette;					// set palette

	ld hl, fade_5 + 63;					// last entry @ 71% intensity
	call set_palette;					// set palette

	ld hl, fade_6 + 63;					// last entry @ 86% intensity
	call set_palette;					// set palette

	ld hl, fade_7 + 63;					// last entry @ 100% intensity
	call set_palette;					// set palette

	call space;							// wait for key press

	ld hl, fade_6 + 63;					// last entry @ 86% intensity
	call set_palette;					// set palette

	ld hl, fade_5 + 63;					// last entry @ 71% intensity
	call set_palette;					// set palette

	ld hl, fade_4 + 63;					// last entry @ 57% intensity
	call set_palette;					// set palette

	ld hl, fade_3 + 63;					// last entry @ 43% intensity
	call set_palette;					// set palette

	ld hl, fade_2 + 63;					// last entry @ 29% intensity
	call set_palette;					// set palette

	ld hl, fade_1 + 63;					// last entry @ 14% intensity
	call set_palette;					// set palette

	ld hl, fade_0 + 63;					// last entry @ 0% intensity
	call set_palette;					// set palette

	jp read_files_2;					// do next entry

;	// subroutines

set_palette:
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
;	ret;								// done

wait:
	ld a, (frame);						// get current frame value
	ld c, a;							// store it

wait2:
	ld a, (frame);						// get frame again
	cp c;								// has it changed?
	jr nz, wait2;						// loop until one frame passed
	halt;								// wait one more frame
	ret;								// return

space:
	ld b, 180;							// frames to wait

space2:
	ld a, $7f;							// high byte of I/O address
	in a, ($fe);						// read byte
	rra;								// set carry if space pressed
	jr c, space3;						// jump if not
	ld b, 2;							// change count

space3;
	call wait;							// wait 2 frames
	djnz space2;
	ret;								// done

load:
	ld a, (handle_f);					// file handle
	rst divmmc;							// issue a hookcode
	defb f_read;						// read bytes
	ret;								// end of subroutine

last_entry:
	ld a, (handle_p);					// get folder handle
	rst divmmc;							// issue a hookcode
	defb f_close;						// close it
	jp read_files;						// loop

fade:
	ld hl, $f800;						// source palette
	ld de, fade_7;						// 100% intensity palette
	ld bc, 64;							// byte count
	ldir;								// copy it

	ld ix, fade_7 + 63;					// last entry of 100% intensity palette

	ld b, 64;							// count
	call wo_blue;						// 1st pass

	ld b, 64;							// count
	call wi_blue;						// 2nd pass

	ld b, 64;							// count
	call wo_blue;						// 3rd pass

	ld b, 64;							// count
	call wi_blue;						// 4th pass

	ld b, 64;							// count
	call wo_blue;						// 5th pass

	ld b, 64;							// count
	call wi_blue;						// 6th pass

;	// the next part is already set to zeros

;	ld b, 64;							// count
;	call wo_blue;						// 7th pass

	ret;								// done

overflow:
	ret nc;		 						// return if no overflow
	xor a;							  	// else clear A
	ret;								// done

wo_blue:
	ld a, (ix);		 					// get entry
	and %11100000;	  					// isolate Green
	sub %00100000;	  					// reduce Green
	call overflow;	 					// test for overflow
	and %11100000;	  					// isolate Green
	ld c, a;							// Green to C

	ld a, (ix);							// get entry
	and %00011100;	  					// isolate Red
	sub %00000100;	  					// reduce Red
	call overflow;	  					// test for overflow
	and %00011100;	  					// isolate Red
	ld d, a;							// Red to D

	ld a, (ix);		 					// get entry
	and %00000011;	  					// isolate Blue

	add a, c;		   					// add Green
	add a, d;		   					// add Red
	ld (ix - 64), a;					// write to next palette set

	dec ix;			 					// next entry
	djnz wo_blue;	   					// do all 64 entrieas
	ret;								// done

wi_blue:
	ld a, (ix);		 					// get entry
	and %11100000;	  					// isolate Green
	sub %00100000;	  					// reduce Green
	call overflow;	  					// test for overflow
	and %11100000;	  					// isolate Green
	ld c, a;							// Green to C

	ld a, (ix);		 					// get entry
	and %00011100;	  					// isolate Red
	sub %00000100;	  					// reduce Red
	call overflow;	  					// test for overflow
	and %00011100;	  					// isolate Red
	ld d, a;							// Red to D

	ld a, (ix);		 					// get entry
	and %00000011;	  					// isolate Blue
	sub %00000001;	  					// reduce Blue
	call overflow;	  					// test for overflow
	and %00000011;	  					// isolate Blue
	ld e, a;							// Blue to E

	xor a;			  					// LD A, 0
	add a, c;		   					// add Green
	add a, d;		   					// add Red
	add a, e;		   					// add Blue
	ld (ix - 64), a;					// write to next palette set

	dec ix;			 					// next entry
	djnz wi_blue;	   					// do all 64 entrieas
	ret;								// done

handle_p:
	defb 0;								// path handle

handle_f:
	defb 0;								// file handle

folder_path:
	defb "/programs/scrshow/rsc", 0;	// folder path

folder_entry:
	defb 0;								// folder entry

;	// palette entries
	org $61b0

fade_0:
	defs 64, 0;							// 0% intensity

fade_1 equ fade_0 + 64
fade_2 equ fade_1 + 64
fade_3 equ fade_2 + 64
fade_4 equ fade_3 + 64
fade_5 equ fade_4 + 64
fade_6 equ fade_5 + 64
fade_7 equ fade_6 + 64
