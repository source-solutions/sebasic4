;	// JUGGLER - An example of how to print text, load data sequentially
;	//           and do full screen animation from disk with a fixed palette

;	// Copyright (c) 2021 Source Solutions, Inc.

;	// OS hook codes
	include "UNODOS3.INC"

	frame equ 23672;					// returns to zero every second
	back_buffer equ $a800;				// upper limit of non-paged RAM
	print_a equ $10;					// print a character
	chan_open equ $1601;				// channel open

	org $6000

;	// print intro text

pr_text:
	ld a, 12;							// FF
	rst print_a;						// clear screen
	ld a, 2;							// select main screen
	call chan_open;						// select channel
	ld hl, text;						// point to text

pr_loop:
	ld a, (hl);							// get character
	and a;								// terminating byte?
	jr z, pr_lower;						// jump if so;
	rst print_a;						// print character
	inc hl;								// point to next character
	jr pr_loop;							// loop until done

pr_lower
	inc hl;								// next position
	push hl;							// stack pointer
	ld a, 1;							// select lower screen
	call chan_open;						// select channel
	pop hl;								// unstack pointer

pr_l_loop:
	ld a, (hl);							// get character
	and a;								// terminating byte?
	jr z, pr_key;						// jump if so;
	rst print_a;						// print character
	inc hl;								// point to next character
	jr pr_l_loop;						// loop until done

pr_key:
	ld a, $7f;							// high byte of I/O address
	in a, ($fe);						// read byte
	rra;								// set carry if space pressed
	jp c, pr_key;						// loop until space pressed

;	// set the palette

setup:
	xor a;								// LD A, 0;
	out ($fe), a;						// set default border
	ld a, %00011101;					// ROM 1, VID 1, RAM 5
	ld (reg), a;						// store it
	ld bc, $7ffd;						// 128 paging
	out (c), a;							// set it
	ld a, %00000010;					// 8x1 attribute mode
	out ($ff), a;						// set it (SCLD)
	ld hl, palette + 63;				// last entry in palette
	call set_palette;					// set the palette

start_movie:
	ld hl, frame_no;					// address frame number (ASCII)
	ld a, '0';							// reset frame number
	ld (hl), a;							// to '00'
	inc hl;
	ld (hl), a;

	call show_frame;					// display frame 01
	call show_frame;					// display frame 02
	call show_frame;					// display frame 03
	call show_frame;					// display frame 04
	call show_frame;					// display frame 05
	call show_frame;					// display frame 06
	call show_frame;					// display frame 07
	call show_frame;					// display frame 08
	call show_frame;					// display frame 09

	ld hl, frame_no;					// address frame number (ASCII)
	inc (hl);							// make it '1'
	inc hl;								// address second ASCII digit
	ld a, '0' - 1;						// will loop to '0'
	ld (hl), a;							// set it

	call show_frame;					// display frame 10
	call show_frame;					// display frame 11
	call show_frame;					// display frame 12
	call show_frame;					// display frame 13
	call show_frame;					// display frame 14
	call show_frame;					// display frame 15
	call show_frame;					// display frame 16
	call show_frame;					// display frame 17
	call show_frame;					// display frame 18
	call show_frame;					// display frame 19

	ld hl, frame_no;					// address frame number (ASCII)
	inc (hl);							// make it '2'
	inc hl;								// address second ASCII digit
	ld a, '0' - 1;						// will loop to '0'
	ld (hl), a;							// set it

	call show_frame;					// display frame 20
	call show_frame;					// display frame 21
	call show_frame;					// display frame 22
	call show_frame;					// display frame 23
	call show_frame;					// display frame 24

	jr start_movie;						// loop

show_frame:
	ld hl, frame_no + 1;				// address second ASCII digit
	inc (hl);							// increment it
	ld ix, frame_no;					// ASCIIZ filename
	call open;							// open file

	ld ix, $c000;						// offset 0 in frame buffer
	ld bc, 6144;						// byte count

	halt;								// wait until the first frame to do the load

	call load;							// load the 1st half of file

	ld ix, $e000;						// offset 1 in frame buffer
	ld bc, 6144;						// byte count
	call load;							// load the 2nd half of the file + palette
	call close;							// close file and return

	ld a, (reg);						// get video / RAM page
	xor %00001010;						// swap RAM and video pages
	ld (reg), a;						// store it
	ld bc, $7ffd;						// 128 paging

	halt;								// wait until the second frame to display the image

	out (c), a;							// set it
	ret;								// done

;	// subroutines

set_palette:
	ld c, $3b;							// palette port
	ld de, $00bf;						// d = data, e = register
	ld a, 64;							// becomes 63
;	halt;								// wait for vblank

palette_loop:
	dec a;								// next register
	ld b, e;							// register port
	out (c), a;							// select register
	ld b, d;							// data port
	outd;								// dec b; out bc, (hl); dec hl
	and a;								// was that the last register?
	jr nz, palette_loop;				// set all 64 entries
	ret;								// done

load:
	ld a, (handle);						// file handle
	rst divmmc;							// issue a hookcode
	defb f_read;						// read bytes
	ret;								// end of subroutine

close:
	ld a, (handle);						// get folder handle
	rst divmmc;							// issue a hookcode
	defb f_close;						// close it
	ret;

open:
	ld a, '*';							// use current drive
	ld b, fa_read | fa_open_ex;			// open for reading if file exists
	rst divmmc;							// issue a hookcode
	defb f_open;						// open file
	ld (handle), a;						// store file handle
	ret;								// end of subroutine

;	// data

frame_no:
	defb "00";							// filename for frame
	defb ".scr", 0;

handle:
	defb 0

reg:
	defb 0

text:
	defb " Juggler (Version 1.2)", 13;
 	defb " Copyright (C) 1986 Eric Graham", 13;
	defb 13;
	defb " The images were generated with a standard Amiga with 512K memory. A ray", 13;
	defb " tracing method was used, which simulates rays of light reflecting within", 13;
	defb " a mathematically defined scene. Each image requires the calculation of", 13;
	defb " 64,000 light rays and takes approximately 1 hour to generate.", 13;
	defb 13;
	defb " The images were cropped to 256 x 192 pixels and combined into a single", 13;
	defb " 1024 x 1152 pixel image. The color palette was reduced from 4096 colors", 13;
	defb " to 64 colors using Photoshop's selective algorithm. These colors were", 13;
	defb " then converted to the G3R3B2 color space to provide a uniform palette.", 13;
	defb 13;
	defb " Taking the three most significant bits for green and red, and the two", 13;
	defb " most significant bits for blue resulted in 50 unique colors. These were", 13;
	defb " then order sorted and distributed across the four CLUTs to provide an", 13;
	defb " optimal palette. The individual images were converted in Image2ULAplus.", 13;
	defb 13
	defb " An image uses 12K bytes for storage. Images are loaded in less than 30", 13;
	defb " milliseconds. A fixed palette is used to avoid having to set the", 13;
	defb " palette registers on each frame. This enables a constant frame rate of", 13;
	defb " 30 frames per second.";
	defb 0;
	defb " NOW PRESS SPACE TO START THE DEMO", 0;

palette:
	incbin "PALETTE.RAW"
