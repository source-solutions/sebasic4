;	// ANIMSCR - A video player for SCR frames with a fixed 17 color palette

;	// Copyright (c) 2022-2023 Source Solutions, Inc.

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
	call SEKeyboardWaitKey;				// wait for a keypress
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
	ld ix, palette;						// first entry in palette
	call SEGraphicsPaletteSet;			// API: set 64 palette registers

start_movie:
	ld hl, frame_no;					// address frame number (ASCII)
	ld a, '0';							// reset frame number
	ld (hl), a;							// to '00'
	inc hl;
	ld (hl), a;

next_frame:
	call show_frame;					// display frame _1
	call show_frame;					// display frame _2
	call show_frame;					// display frame _3
	call show_frame;					// display frame _4
	call show_frame;					// display frame _5
	call show_frame;					// display frame _6
	call show_frame;					// display frame _7
	call show_frame;					// display frame _8
	call show_frame;					// display frame _9

	ld hl, frame_no;					// address frame number (ASCII)
	inc (hl);							// increment the 10s column
	inc hl;								// address second ASCII digit
	ld a, '0' - 1;						// will loop to '0'
	ld (hl), a;							// set it

	call show_frame;					// display frame _0

	jr next_frame;						// loop over next 10 frames

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

load:
	ld a, (handle);						// file handle
	jp SEFileRead;						// exit via read file vector

close:
	ld a, (handle);						// get folder handle
	jp SEFileClose;						// exit via close file vector

open:
	call SEFileOpenExists;				// open file

	jp c, start_movie;					// jump to start if the file doesn't exist

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
	defb " AnimSCR - version 1.1", 13
 	defb " Copyright (C) 2022-2023 Source Solutions, Inc.", 13
	defb 13
	defb " Convert animated GIF images to single frames using Image Magcik:", 13
	defb " https://www.imagemagick.org/Usage/anim_basics/#adjoin", 13
	defb 13
	defb " Or, convert video to single frames with ffmpeg:", 13
	defb " https://ffmpeg.org/ffmpeg.html#Video-and-Audio-file-format-conversion", 13
	defb 13
	defb " Then bulk convert images in DaDither using a fixed 17 color palette", 13
	defb " (the DADITHER.PAL file in the SRC folder): https://www.dadither.com/", 13
	defb 13
	defb " Platform: ZX Spectrum UlaPlus        Screen: 256x192x8 (8x1)", 13
	defb " Palette:  v1.1 (17 from 256, fast)   Fixed palette: DADITHER.PAL", 13
	defb 13
	defb " Method: Try converting a single frame first to find the optimal method.", 13
	defb " Playback rate is 30FPS so Atkinson is often a good choice to reduce noise.", 13
	defb 13
	defb " Currently the player supports up to 99 frames of animation (01 to 99).", 13
	defb 13
	defb " You can strip the last 64 bytes of palette data from the SCR files.", 13
	defb " With trimmed files, 99 frames is still over a megabyte of data.", 13
	defb 0

text_lo:
	defb " NOW PRESS SPACE TO START THE MOVIE", 0

palette:
	incbin "PALETTE.RAW"
