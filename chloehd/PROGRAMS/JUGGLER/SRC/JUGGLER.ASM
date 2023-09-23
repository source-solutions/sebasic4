;	// JUGGLER - An example of how to print text, load data sequentially
;	//           and do full screen animation from disk with a fixed palette

;	// Copyright (c) 2021 Source Solutions, Inc.

;	// system headers
	include "../../../SYSTEM/HEADERS/SYSTEM.INC"

	frame equ 23672;					// returns to zero every second
	back_buffer equ $a800;				// upper limit of non-paged RAM
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
	ld ix, palette;						// last entry in palette
	call SEGraphicsPaletteSet;					// API: set 64 palette registers
	call mute_psg;						// sound off

start_movie:
	ld hl, frame_no;					// address frame number (ASCII)
	ld a, '0';							// reset frame number
	ld (hl), a;							// to '00'
	inc hl;
	ld (hl), a;

	call boink

	call show_frame;					// display frame 01

	call mute_psg

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

mute_psg:
	ld hl, $fe07;						// H = AY-0, L = Volume register (7)
	ld de, $bfff;						// D = data port, E = register port / mute
	ld c, $fd;							// low byte of AY port
	call mute_ay;						// mute AY-0
	inc h;								// AY-1

mute_ay:
	ld b, e;							// AY register port
	out (c), h;							// select AY (255/254)
	out (c), l;							// select register
	ld b, d;							// AY data port
	out (c), e;							// AY off;
	ret;								// end of subroutine

boink:
	ld hl, $fe07;						// H = AY-0, L = Volume register (7)
	ld de, $bfff;						// D = data port, E = register port / mute
	ld c, $fd;							// low byte of AY port

	ld b, e;							// AY register port
	ld a, 7;							// mixer
	out (c), a;							// select register
	ld b, d;							// AY data port
	ld a, %00011011;					// enable noise and tone on channel C					
	out (c), a;							// write data;

	ld b, e;							// AY register port
	ld a, 10;							// C: envelope / volume
	out (c), a;							// select register
	ld b, d;							// AY data port
	ld a, %00011111;					// envelope on, full volume
	out (c), a;							// write data;

	ld b, e;							// AY register port
	ld a, 13;							// envelope shape / cycle
	out (c), a;							// select register
	ld b, d;							// AY data port
	ld a, %00001001;					// \____
	out (c), a;							// write data;

	ld b, e;							// AY register port
	ld a, 11;							// fine
	out (c), a;							// select register
	ld b, d;							// AY data port
	ld a, 0;							// envelope						
	out (c), a;							// write data;

	ld b, e;							// AY register port
	ld a, 12;							// coarse
	out (c), a;							// select register
	ld b, d;							// AY data port
	ld a, 18;							// envelope							
	out (c), a;							// write data;

	ld b, e;							// AY register port
	ld a, 1;							// coarse
	out (c), a;							// select register
	ld b, d;							// AY data port
	ld a, 0;							// pitch
	out (c), a;							// write data;

	ld b, e;							// AY register port
	ld a, 0;							// fine
	out (c), a;							// select register
	ld b, d;							// AY data port
	ld a, 14;							// pitch
	out (c), a;							// write data;

	ret;								// done

load:
	ld a, (handle);						// file handle
	jp SEFileRead;						// exit via read file vector

close:
	ld a, (handle);						// get folder handle
	jp SEFileClose;						// exit via close file vector

open:
	call SEFileOpenExists;				// open file
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
	defb " Juggler - version 1.3", 13;
 	defb " Copyright (C) 1986 Eric Graham", 13;
	defb 13;
	defb " The images were generated with a standard Amiga with 512K memory. A ray", 13;
	defb " tracing method was used, which simulates rays of light reflecting within", 13;
	defb " a mathematically defined scene. Each image requires the calculation of", 13;
	defb " 64,000 light rays and takes approximately one hour to generate.", 13;
	defb 13;
	defb " The images were cropped to 256x192 pixels and combined into a single", 13;
	defb " 1024x1152 pixel image. The color palette was reduced from 4096 colors", 13;
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

text_lo:
	defb 0;
	defb "NOW PRESS SPACE TO START THE DEMO", 0;

palette:
	incbin "PALETTE.RAW"
