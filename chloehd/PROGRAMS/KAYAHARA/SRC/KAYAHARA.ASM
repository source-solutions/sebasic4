;	// Kayahara - An example of how to load data into the sideways RAM
;	// Copyright (c) 2019 Source Solutions, Inc.
;	// Based on Nobuyuki Kayahara's 'Silhouette Illusion'
;	// http://www.procreo.jp/labo/labo13.html

;	// datamap

;	// D7h - frame 13		X7h - frame 27		H0d - frame 19
;	// D7l - frame 12		X7l - frame 26		H0c - frame 05
;	// D6h - frame 11		X6h - frame 25		H0b - frame 33
;	// D6l - frame 10		X6l - frame 24		H0a - frame 32
;	// D5h - frame 09		X5h - frame 23		H2d - frame 31
;	// D5l - frame 08		X5l - frame 22		H2c - frame 30
;	// D4h - frame 07		X4h - frame 21		H2b - frame 29
;	// D4l - frame 06		X4l - frame 20		H2a - frame 28

;	// D3h					X3h					H5d - attributes 1 followed by code
;	// D3l					X3l					H5c - screen 1

;	// D2h					X2h					H5b - attributes 0
;	// D2l - frame 04		X2l - frame 18		H5a - screen 0

;	// D1h - frame 03		X1h - frame 17		R1d - ROM
;	// D1l - frame 02		X1l - frame 16		R1c - ROM
;	// D0h - frame 01		X0h - frame 15		R1b - ROM
;	// D0l - frame 00		X0l - frame 14		R1a - ROM

;	// system headers
	include "../../../SYSTEM/HEADERS/SYSTEM.INC"

;	// SCLD control
	scld equ $ff;

	lo_0 equ %000
	lo_1 equ %001
	med equ %010
	hi equ %110
	
	dock equ %00000000
	exr equ %10000000

;	// ULA
	ula equ $fe

;	// MMU control (sideways RAM)
	mmu equ $f4

	sr_0 equ %00000001
	sr_1 equ %00000010
	sr_2 equ %00000100
	sr_3 equ %00001000
	sr_4 equ %00010000
	sr_5 equ %00100000
	sr_6 equ %01000000
	sr_7 equ %10000000

;	// paging (home bank)
	paging equ $7ffd;

	ram_0 equ %00000;
	ram_1 equ %00001;
	ram_2 equ %00010;
	ram_3 equ %00011;
	ram_4 equ %00100;
	ram_5 equ %00101;
	ram_6 equ %00110;
	ram_7 equ %00111;

	vid_0 equ %00000;
	vid_1 equ %01000;

	rom_0 equ %00000;
	rom_1 equ %10000;

;	// file handle
	handle equ $7fff

;	// constants
	print_a equ $10;					// print a character
	chan_open equ $1601;				// channel open

;	// app entry address
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
	di;									// interrupts off

	ld a, rom_1 + vid_1 + ram_7;		// top page of RAM to HOME-7
	ld bc, paging;						// get ready to page
	out (c), a;							// set paging;

	xor a;								// LD A, 0
	ld hl, $c000;						// source
	ld (hl), a;							// clear first byte
	ld de, $c001;						// destination
	ld bc, $3fff;						// byte count (16K)
	ldir;								// clear screen

	out (ula), a;						// set a black border
	out (scld), a;						// select DOCK bank and low res screen (vid 1)

	ld sp, $7fff;						// move stack

	ld a, rom_1 + vid_1 + ram_5;		// top page of RAM to HOME-5
	ld bc, paging;						// get ready to page
	out (c), a;							// set paging;

	ld hl, $6000;						// source
	ld de, $e000;						// destination
	ld bc, $2000;						// byte count (8K)
	ldir;								// clone shadow RAM in $6000-$7FFF to main RAM

	xor a;								// LD A, 0;
	out (mmu), a;						// page out all shadow RAM

	ld a, rom_1 + vid_1 + ram_0;		// top page of RAM to HOME-0
	ld bc, paging;						// get ready to page
	out (c), a;							// set paging;

	ld ix, frames;						// point to data
	call open;							// open file for reading

	ld bc, 24576;						// frames 0 to 5
	call fread;							// read it to $8000

	ld a, sr_0 + sr_1 + sr_2;			// shadow RAM D:_____210
	out (mmu), a;						// set it

	ld hl, $8000;						// source
	ld de, 0;							// destination
	ld bc, 20480;						// five frames to copy
	ldir;								// copy it

	ld hl, $d000;						// source
	ld de, $e000;						// destination
	ld bc, 4096;						// one frame to copy
	ldir;								// copy it

	ld a, sr_4 + sr_5 + sr_6 + sr_7;	// shadow RAM D:7654____
	out (mmu), a;						// set it

	ld bc, 32768;						// frames 6 to 13
	call fread;							// read it to $8000

	xor a;								// unpage all shadow RAM
	out (mmu), a;						// set it

	ld bc, 24576;						// frames 14 to 19
	call fread;							// read it to $8000

	ld a, exr;							// select EX bank
	out (scld), a;						// set it

	ld a, sr_0 + sr_1 + sr_2;			// shadow RAM X:_____210
	out (mmu), a;						// set it

	ld hl, $8000;						// source
	ld de, 0;							// destination
	ld bc, 20480;						// six frames to copy
	ldir;								// copy it

	ld hl, $d000;						// source
	ld de, $f000;						// destination
	ld bc, 4096;						// one frame to copy
	ldir;								// copy it

	ld a, sr_4 + sr_5 + sr_6 + sr_7;	// shadow RAM X:7654____
	out (mmu), a;						// set it

	ld bc, 32768;						// frames 20 - 27
	call fread;							// read it to $8000

	xor a;								// unpage all shadow RAM
	out (mmu), a;						// set it

	ld bc, 24576;						// frames 28 to 33
	call fread;							// read it to $8000
	call close;							// close file

;	// load logo
	ld ix, logo;						// point to data
	call open;							// open file for reading

	ld ix, $5000;						// lower third of screen area
	ld bc, 2048;						// logo
	call read_logo;						// read it
	call close;							// close file

;	// copy logo to shadow screen
	ld hl, $5000;						// source
	ld de, $7000;						// destination
	ld bc, 2048;						// byte count
	ldir;								// copy it

	ld a, $7b;							// high byte of $7bff
	ld i, a;							// set interrupt routine address
	im 2;								// interrupt mode 2
	ei;									// enable interrupts

	ld a, lo_0 + dock;					// VRAM0, DOCK bank
	out (scld), a;						// switch screen

	ld a, rom_1 + vid_0 + ram_0;		// video page 0
	ld bc, paging;						// get ready to page
	out (c), a;							// set paging;

	ld bc, $bf3b;						// ULAplus register select
	xor a;								// LD A, 0;
	out (c), a;							// select it
	ld b, $ff;							// select data port
	ld a, 0;							// black
	out (c), a;							// set it

	jp start;							// skip shadow screen area

;	// file handling (cannot use SE Basic IV DOS API because entire shadow RAM is used as buffer)
open:
	ld a, '*';							// use current drive
	ld b, fa_read | fa_open_ex;			// open for reading if file exists
	rst divmmc;							// issue a hookcode
	defb f_open;						// open file
	ld (handle), a;						// store file handle
	ret;								// end of subroutine

fread:
	ld ix, $8000;						// load in fast RAM

read_logo:
	ld a, (handle);						// restore handle
	rst divmmc;							// issue a hookcode
	defb f_read;						// read file
	ret;								// end of subroutine

close:
	ld a, (handle);						// restore handle
	rst divmmc;							// issue a hookcode
	defb f_close;						// close file
	ret;								// end of subroutine

frames:
	defb "frames.bin", 0;				// 34 frames, 2K each

logo:
	defb "logo.bin", 0;					// logo for lower third (2K)

;	// program below this address will be overwritten
	org $7bff
	defw mask_int_2

mask_int_2:
	ei;									// enable interrupts
	reti;								// return

cycle:
	ld a, (handle);						// handy counter
	and a;								// test for zero
	jr nz, not_zero;					// jump if not
	inc a;								// skip if so

not_zero:
	ld bc, $ff3b;						// ULAplus data port
	out (c), a;							// select it
	inc a;								// advance it
	ld (handle), a;						// write it back
	ret;								// end of subroutine

;	// frame 00
start:
	call cycle;							// cycle palette

	ld a, sr_0 + sr_1;					// shadow RAM D:______10
	out (mmu), a;						// set it
	ld hl, $0000;						// frame
	ld de, $6000;						// VRAM 1
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_1 + dock;					// VRAM1, DOCK bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 01
	ld hl, $1000;						// frame
	ld de, $4000;						// VRAM 0
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_0 + dock;					// VRAM1, DOCK bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 02
	ld hl, $2000;						// frame
	ld de, $6000;						// VRAM 1
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_1 + dock;					// VRAM1, DOCK bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 03
	ld hl, $3000;						// frame 0
	ld de, $4000;						// VRAM 0
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_0 + dock;					// VRAM1, DOCK bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 04
	ld a, sr_2;							// shadow RAM D:_____2__
	out (mmu), a;						// set it
	ld hl, $4000;						// frame
	ld de, $6000;						// VRAM 1
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_1 + dock;					// VRAM1, DOCK bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 05
	xor a;								// LD A, 0;
	out (mmu), a;						// page out all shadow RAM
	ld hl, $e000;						// frame
	ld de, $4000;						// VRAM 0
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_0 + dock;					// VRAM1, DOCK bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 06
	ld a, sr_4 + sr_5 + sr_6 + sr_7;	// shadow RAM D:7654____
	out (mmu), a;						// set it
	ld hl, $8000;						// frame
	ld de, $6000;						// VRAM 1
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_1 + dock;					// VRAM1, DOCK bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 07
	ld hl, $9000;						// frame
	ld de, $4000;						// VRAM 0
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_0 + dock;					// VRAM1, DOCK bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 08
	ld hl, $a000;						// frame
	ld de, $6000;						// VRAM 1
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_1 + dock;					// VRAM1, DOCK bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 09
	ld hl, $b000;						// frame
	ld de, $4000;						// VRAM 0
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_0 + dock;					// VRAM1, DOCK bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 10
	ld hl, $c000;						// frame
	ld de, $6000;						// VRAM 1
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_1 + dock;					// VRAM1, DOCK bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 11
	ld hl, $d000;						// frame
	ld de, $4000;						// VRAM 0
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_0 + dock;					// VRAM1, DOCK bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 12
	ld hl, $e000;						// frame 0
	ld de, $6000;						// VRAM 1
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_1 + dock;					// VRAM1, DOCK bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 13
	ld hl, $f000;						// frame 0
	ld de, $4000;						// VRAM 0
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_0 + dock;					// VRAM1, DOCK bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 14
	ld a, lo_0 + exr;					// VRAM0, DOCK bank
	out (scld), a;						// switch screen
	ld a, sr_0 + sr_1;					// shadow RAM D:______10
	out (mmu), a;						// set it
	ld hl, $0000;						// frame
	ld de, $6000;						// VRAM 1
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_1 + exr;					// VRAM1, exr bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 15
	ld hl, $1000;						// frame
	ld de, $4000;						// VRAM 0
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_0 + exr;					// VRAM1, exr bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 16
	ld hl, $2000;						// frame
	ld de, $6000;						// VRAM 1
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_1 + exr;					// VRAM1, exr bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 17
	call cycle;							// cycle palette

	ld hl, $3000;						// frame 0
	ld de, $4000;						// VRAM 0
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_0 + exr;					// VRAM1, exr bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 18
	ld a, sr_2;							// shadow RAM X:_____2__
	out (mmu), a;						// set it
	ld hl, $4000;						// frame
	ld de, $6000;						// VRAM 1
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_1 + exr;					// VRAM1, exr bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 19
	xor a;								// LD A, 0;
	out (mmu), a;						// page out all shadow RAM
	ld hl, $f000;						// frame
	ld de, $4000;						// VRAM 0
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_0 + exr;					// VRAM1, exr bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 20
	ld a, sr_4 + sr_5 + sr_6 + sr_7;	// shadow RAM X:7654____
	out (mmu), a;						// set it
	ld hl, $8000;						// frame
	ld de, $6000;						// VRAM 1
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_1 + exr;					// VRAM1, exr bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 21
	ld hl, $9000;						// frame
	ld de, $4000;						// VRAM 0
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_0 + exr;					// VRAM1, exr bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 22
	ld hl, $a000;						// frame
	ld de, $6000;						// VRAM 1
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_1 + exr;					// VRAM1, exr bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 23
	ld hl, $b000;						// frame
	ld de, $4000;						// VRAM 0
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_0 + exr;					// VRAM1, exr bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 24
	ld hl, $c000;						// frame
	ld de, $6000;						// VRAM 1
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_1 + exr;					// VRAM1, exr bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 25
	ld hl, $d000;						// frame
	ld de, $4000;						// VRAM 0
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_0 + exr;					// VRAM1, exr bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 26
	ld hl, $e000;						// frame 0
	ld de, $6000;						// VRAM 1
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_1 + exr;					// VRAM1, exr bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 27
	ld hl, $f000;						// frame 0
	ld de, $4000;						// VRAM 0
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_0 + exr;					// VRAM1, exr bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 28
	xor a;								// unpage all shadow RAM
	out (mmu), a;						// set it
	ld hl, $8000;						// frame
	ld de, $6000;						// VRAM 1
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_1 + dock;					// VRAM1, DOCK bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 29
	ld hl, $9000;						// frame
	ld de, $4000;						// VRAM 0
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_0 + dock;					// VRAM1, DOCK bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 30
	ld hl, $a000;						// frame
	ld de, $6000;						// VRAM 1
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_1 + dock;					// VRAM1, DOCK bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 31
	ld hl, $b000;						// frame 0
	ld de, $4000;						// VRAM 0
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_0 + dock;					// VRAM1, DOCK bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 32
	ld hl, $c000;						// frame
	ld de, $6000;						// VRAM 1
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_1 + dock;					// VRAM1, DOCK bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

;	// frame 33
	ld hl, $d000;						// frame
	ld de, $4000;						// VRAM 0
	ld bc, 4096;						// byte count
	ldir;								// copy it
	ld a, lo_0 + dock;					// VRAM1, DOCK bank
	halt;								// wait for v-blank
	halt;								// wait for v-blank
	out (scld), a;						// switch screen

	jp start;

text:
	defb "Kayahara - version 1.3", 13;
 	defb "Copyright (C) 2003 Nobuyuki Kayahara", 13;
	defb 13;
	defb "The ", '"', "Spinning Dancer", '"', ", also known as the ", '"', "Silhouette Illusion", '"', ", is a kinetic,", 13;
	defb "bistable, animated optical illusion originally distributed as a GIF animation.", 13;
	defb "Created in 2003 by web designer Nobuyuki Kayahara, the illusion derives from the", 13;
	defb "lack of visual clues for depth. The direction of spin depends on the observer.", 13;
	defb 13;
	defb "When facing left or right, the ponytail indicates the direction of travel, but", 13;
	defb "it is not obvious which leg is which. However, when not facing left or right,", 13;
	defb "the dancer can be seen as facing toward or away from the viewer. The dancer can", 13;
	defb "be percieved to rotate clockwise, counter-clockwise, or to pivot back and forth.", 13;
	defb 13;
	defb "Curiously, if you place a mirror vertically next to the image, both the original", 13;
	defb "and the reflection may be seen to spin in the same direction. From 2008 to 2009,", 13;
	defb "the animation appeared in the popular internet ", '"', "right brain-left brain test", '"', " to", 13;
	defb "determine the viewer's dominant hemisphere. The animation doesn't work this way.", 13;
	defb 13;
	defb "This demo was originally written as a memory test for an earlier version of the", 13;
	defb "Chloe hardware. Each frame is stored as a 4K image in RAM, for 136K in total.", 13;
	defb "All 128K of shadow RAM and part of the main RAM is used with paging between each", 13;
	defb "image. In this version the anamtion is synced to the interrupt at 30 FPS.", 13;
	defb 0;

text_lo:
	defb "NOW PRESS SPACE TO START THE DEMO", 0;
