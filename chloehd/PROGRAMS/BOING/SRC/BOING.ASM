;	// BOING - Another example of how to print text, load data sequentially
;	//         and do full screen animation from disk with a fixed palette

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
;	ld hl, palette + 63;				// last entry in palette
;	call set_palette;					// set the palette
	ld ix, palette;						// first entry in palette
	call SEGraphicsPaletteSet;			// API: set 64 palette registers

	call mute_psg

start_movie:
	ld hl, frame_no;					// address frame number (ASCII)
	ld a, '0';							// reset frame number
	ld (hl), a;							// to '00'
	inc hl;
	ld (hl), a;
	call show_frame;					// display frame 01

	call boink;							// key frame

	call do_eight;						// display frame 02 to 09
	call do_seven;						// display frame 10 to 16

	call boink;							// key frame

	call do_three;						// display frame 17 to 19
	call do_ten;						// display frame 20 to 29
	call do_ten;						// display frame 30 to 39 - key frame 31 does not require sound
	call do_seven;						// display frame 40 to 46

	call boink;							// key frame

	call do_three;						// display frame 47 to 49
	call do_ten;						// display frame 50 to 59
	call do_two;						// display frame 60 to 61

	call boink;							// key frame

	call show_prev_frame;				// display frame 60
	call do_prev_ten;					// dislpay frame 59 to 50
	call do_prev_four;					// display frame 49 to 46

	call boink;							// key frame

	call do_pr_6;						// dislpay frame 45 to 40
	call do_prev_ten;					// dislpay frame 39 to 30
	call do_prev_ten;					// dislpay frame 29 to 20
	call do_prev_four;					// display frame 19 to 16

	call boink;							// key frame

	call do_pr_6;						// dislpay frame 15 to 10
	call do_prev_eight;					// dislpay frame 09 to 02
	jr start_movie;						// loop

do_seven:
	call show_frame;					// display frame _0
	call show_frame;					// display frame _1
	call show_frame;					// display frame _2
	call show_frame;					// display frame _3
	call show_frame;					// display frame _4

do_two:
	call show_frame;					// display frame _5
	call show_frame;					// display frame _6
	ret;

do_ten:
	call show_frame;					// display frame _0

do_nine:
	call show_frame;					// display frame _1

do_eight:
	call show_frame;					// display frame _2
	call show_frame;					// display frame _3
	call show_frame;					// display frame _4
	call show_frame;					// display frame _5
	call show_frame;					// display frame _6

do_three:
	call show_frame;					// display frame _7
	call show_frame;					// display frame _8
	call show_frame;					// display frame _9
	ld hl, frame_no;					// address frame number (ASCII)
	inc (hl);							// increment it
	inc hl;								// address second ASCII digit
	ld a, '0' - 1;						// will loop to '0'
	ld (hl), a;							// set it
	ret;								// done

do_prev_four:
	ld hl, frame_no;					// address frame number (ASCII)
	dec (hl);							// decrement it
	inc hl;								// address second ASCII digit
	ld a, '9' + 1;						// will loop to '9'
	ld (hl), a;							// set it
	jr do_pr_4;							// display frame _9 to _6

do_prev_ten:
	ld hl, frame_no;					// address frame number (ASCII)
	dec (hl);							// decrement it
	inc hl;								// address second ASCII digit
	ld a, '9' + 1;						// will loop to '9'
	ld (hl), a;							// set it
	call show_prev_frame;				// display frame _9
	call show_prev_frame;				// display frame _8

do_pr_8:
	call show_prev_frame;				// display frame _7
	call show_prev_frame;				// display frame _6

do_pr_6:
	call show_prev_frame;				// display frame _5
	call show_prev_frame;				// display frame _4

do_pr_4:
	call show_prev_frame;				// display frame _3
	call show_prev_frame;				// display frame _2
	call show_prev_frame;				// display frame _1
	jp show_prev_frame;					// display frame _0 and return

do_prev_eight:
	ld hl, frame_no;					// address frame number (ASCII)
	dec (hl);							// decrement it
	inc hl;								// address second ASCII digit
	ld a, '9' + 1;						// will loop to '9'
	ld (hl), a;							// set it
	jr do_pr_8;							// do previous nine

show_prev_frame:
	ld hl, frame_no + 1;				// address second ASCII digit
	dec (hl);							// decrese it
	jr show_any;						// rest of routine

show_frame:
	ld hl, frame_no + 1;				// address second ASCII digit
	inc (hl);							// increment it

show_any:
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
	ld (handle), a;						// store file handle
	ret;								// end of subroutine

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
	ld a, 6;							// noise period
	out (c), a;							// select register
	ld b, d;							// AY data port
	ld a, %00000110;					// 5-bit period control
	out (c), a;							// write data;

	ld b, e;							// AY register port
	ld a, 7;							// mixer
	out (c), a;							// select register
	ld b, d;							// AY data port
	ld a, %00000111;					// enable noise on channel A to C					
	out (c), a;							// write data;

	ld b, e;							// AY register port
	ld a, 8;							// A: envelope / volume
	out (c), a;							// select register
	ld b, d;							// AY data port
	ld a, %00010110;					// envelope on, full volume
	out (c), a;							// write data;

	ld b, e;							// AY register port
	ld a, 9;							// B: envelope / volume
	out (c), a;							// select register
	ld b, d;							// AY data port
	ld a, %00010110;					// envelope on, full volume
	out (c), a;							// write data;

	ld b, e;							// AY register port
	ld a, 10;							// C: envelope / volume
	out (c), a;							// select register
	ld b, d;							// AY data port
	ld a, %00010110;					// envelope on, full volume
	out (c), a;							// write data;

	ld b, e;							// AY register port
	ld a, 12;							// coarse
	out (c), a;							// select register
	ld b, d;							// AY data port
	ld a, 56;							// envelope							
	out (c), a;							// write data;

	ld b, e;							// AY register port
	ld a, 13;							// envelope shape / cycle
	out (c), a;							// select register
	ld b, d;							// AY data port
	ld a, 8;							// \|\|\|\|\|\|\|\
	out (c), a;							// write data;

	ret;								// done

;	// data

frame_no:
	defb "00";							// filename for frame
	defb ".scr", 0;

handle:
	defb 0

reg:
	defb 0

text:
	defb "Boing Ball - version 1.2", 13;
 	defb "Copyright (C) 2021-2023 Source Solutions, Inc.", 13;
	defb 13;
	defb "The original version of this demo was created by Robert J. Mical and Dale Luck", 13;
	defb "for the 1984 Consumer Electronics Show (CES) in Las Vegas. It was designed to", 13;
	defb "show off the custom chips in the prototype Amiga. Written in a single night,", 13;
	defb "aided only by warm beer, it originally lacked horizontal movement and sound.", 13;
	defb 13;
	defb "The effect was created using palette cycling and bit planes to move a static", 13;
	defb "image around the screen with the appearance of rotation. The entire 32 color", 13;
	defb "palette was required, despite the image using only seven unique colors.", 13;
	defb "The sound effect was created by hitting a garage door with a foam bat.", 13;
	defb 13;
	defb "The final design for the Chloe 280SE hardware would be able to produce an", 13;
	defb "exact copy of the original demo. But since that's not ready yet, this demo", 13;
	defb "uses 61 images, streamed from disk at 30 frames per second. Each images was", 13;
	defb "created by hand in Photoshop. They were then combined into an animated GIF.", 13;
	defb 13;
	defb "The individual images were converted by Image2ULAplus to 8x1 attribute format.", 13;
	defb "The player loops backwards and forwards between the images to give the", 13 ;
	defb "appearance of perpetual movement. As with the original demo, the sound effect", 13;
	defb "was added at a later date. Instead of a sample, it uses the PSG noise channel.";
	defb 0;

text_lo:
	defb "NOW PRESS SPACE TO START THE DEMO", 0;

palette:
	incbin "PALETTE.RAW"
