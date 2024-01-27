;	// AAFALL - An example of palette cycling,
;	// Copyright (c) 2024 Source Solutions, Inc.

;	// system headers
	include "../../../SYSTEM/HEADERS/SYSTEM.INC"

;	// constants
	print_a equ $10;					// print a character
	chan_open equ $1601;				// channel open
	frame equ 23672;					// returns to zero every second

	org $6000

	call pr_text;						// print intro text

;	// original start

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
	ld ix, folder_path;					// folder path buffer
	call SEFolderOpen;					// open folder
	ld (handle_p), a;					// store path handle

read_files_2:
	ld ix, folder_entry;				// buffer
	ld a, (handle_p);					// get path handle
	call SEFolderRead;					// read a folder entry
	or a;								// last entry?
	jp z, last_entry;					// jump if so
	ld hl, folder_entry;				// buffer
	ld a, (hl);							// attibutes to A
	and %00010000;						// folder?
	jr nz, read_files_2;				// skip folders

	ld ix, folder_entry + 1;			// ASCIIZ filename
	call SEFileOpenExists;				// open file
	ld (handle_f), a;					// store file handle

	ld ix, $c000;						// offset 0 in frame buffer
	ld bc, 6144;						// byte count
	call load;							// load the 1st half of file

	ld ix, $e000;						// offset 1 in frame buffer
	ld bc, 6208;						// byte count
	call load;							// load the 2nd half of the file + palette

	ld a, (handle_f);					// file handle
	call SEFileClose;					// close file

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

	jp cycle_start;						// do palette cycling
;---

;	call space;							// wait for key press
;
;	ld hl, fade_6 + 63;					// last entry @ 86% intensity
;	call set_palette;					// set palette
;
;	ld hl, fade_5 + 63;					// last entry @ 71% intensity
;	call set_palette;					// set palette
;
;	ld hl, fade_4 + 63;					// last entry @ 57% intensity
;	call set_palette;					// set palette
;
;	ld hl, fade_3 + 63;					// last entry @ 43% intensity
;	call set_palette;					// set palette
;
;	ld hl, fade_2 + 63;					// last entry @ 29% intensity
;	call set_palette;					// set palette
;
;	ld hl, fade_1 + 63;					// last entry @ 14% intensity
;	call set_palette;					// set palette
;
;	ld hl, fade_0 + 63;					// last entry @ 0% intensity
;	call set_palette;					// set palette
;
;	jp read_files_2;					// do next entry

;---


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
	jp SEFileRead;						// exit via read file vector

last_entry:
	ld a, (handle_p);					// get folder handle
	call SEFileClose;					// close file
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
	defb "/programs/aafall/rsc", 0;	// folder path

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

;	// print intro text
pr_text:
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
	ret;								// end of subroutine

text:
	defb "Aafall - version 1.0", 13;
 	defb "Copyright (C) 2024 Source Solutions, Inc.", 13;
	defb 13;
	defb "The original version of the animated waterfall in this demo was created by Dave", 13;
	defb "Staugas. A programmer at Atari, he wrote Krull and Millipede for the 2600 before", 13;
	defb "going on to work on the operating system for the Atari ST. He also wrote the", 13;
	defb "first graphic editor for the ST called NeoChrome. He created the waterfall image", 13;
	defb "to show off the animation possibilities of palette cycling.", 13;
	defb 13;
	defb "Palette cycling is something of a lost art now, but in the past it was used to", 13;
	defb "produce animation without the large CPU and data overheads. Images are drawn in", 13;
	defb "such a way that changing the value of a set number of palette entries gives the", 13;
	defb "illusion of movement. The waterfall image uses eight of the 16 available colors.", 13;
	defb 13;
	defb "The screen mode used in this demo has a maximum of 64 colors. But it also has", 13;
	defb "attributes that limit you to two colors in a row of eight pixels. In practice,", 13;
	defb "you need to use 48 palette entries to be able to use any of 17 colors in the", 13;
	defb "foreground or background. As such, 23 palette entries are used for cycling.", 13;
	defb 13;
	defb "The original image was modified in a hex editor to make each color unique. Then", 13;
	defb "it was converted to PNG format with GraphicConverter 12 and to an SCR image", 13;
	defb "with DaDither, using a 16 color palette file derived from the original image.", 13;
	defb 0;

text_lo:
	defb "NOW PRESS SPACE TO START THE SHOW", 0;

;	// palette cycling
cycle_start:
	ld ix, palette - 1;					// point to palette entries
	ld l, 8;							// count
	ld c, $3b;							// palette port
	ld de, $ffbf;						// d = data, e = register

cycle_loop:
	ld iy, regs - 3;					// point to register entries
	dec l;								// reduce count
	jr z, cycle_start;					// start over at zero
	push ix;							// stack palette pointer
	call do_cycle;						// set the colors
	pop ix;								// unstack palette pointer
	dec ix;								// to next position
	jr cycle_loop;						// go around again

do_cycle:
	halt;								// wait for vblank
	halt;
	halt;
	halt;
	halt;
	halt;

	call set_three;						// 1st color
	call set_three;						// 2nd color
	call set_three;						// 3rd color
	call set_three;						// 4th color
	call set_three;						// 5th color
	call set_three;						// 6th color
	call set_three;						// 7th color
;										// 8th color

set_three:
	inc ix;								// next color entry
	inc iy;								// next set of three registers
	inc iy;
	inc iy;
	ld h, (ix);							// first color
	ld a, (iy);							// first register
	call set_reg;						// set it
	ld a, (iy + 1);						// second register
	call set_reg;						// set it
	ld a, (iy + 2);						// third register

set_reg:
	ld b, e;							// register port
	out (c), a;							// select register
	ld b, d;							// data port
	out (c), h;							// set color
	ret;


	defb            %11010011;			// duplicates
	defb %10101111, %01100111;
	defb %00100011, %00000010;
	defb %01101111, %10101111;

palette:
	defb %11110111, %11010011;			// palette entries 
	defb %10101111, %01100111;
	defb %00100011, %00000010;
	defb %01101111, %10101111;

regs:
	defb 16, 32, 41;					// register entires
	defb 17, 33, 42;
	defb 18, 34, 43;
	defb 19, 35, 44;
	defb 20, 36, 45;
	defb 21, 37, 46;
	defb 22, 38, 47;
	defb 23, 39, 39;
