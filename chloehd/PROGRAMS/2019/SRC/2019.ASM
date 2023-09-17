;	// 2019 - An example of how to load data sequentially and
;	//        scroll a 1-bit BMP file vertically across the screen

;	// Copyright (c) 2020-2023 Source Solutions, Inc.

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

;	// original start

setup:
	xor a;								// LD A, 0;
	out ($fe), a;						// set default border
	ld a, %00011111;					// ROM 1, VID 1, RAM 7
	ld (reg), a
	ld bc, $7ffd;						// 128 paging
	out (c), a;							// set it
	ld a, %00000010;					// 8x1 attribute mode
	out ($ff), a;						// set it (SCLD)
	ld hl, fade_0 + 63;					// last entry @ 0% intensity
	call set_palette;					// make the screen black

startshow:
	ld hl, slide_no;					// address slide number (ASCII)
	ld a, '0';							// reset slide number
	ld (hl), a;							// to '00'
	inc hl;
	ld (hl), a;

	call show_slide;					// display slide 01
	call show_slide;					// display slide 02
	call show_slide;					// display slide 03

	call roll_text;						// do scroll

	call show_slide;					// display slide 04
	call show_slide;					// display slide 05
	call show_slide;					// display slide 06
	call show_slide;					// display slide 07
	call show_slide;					// display slide 08
	call show_slide;					// display slide 09

	ld hl, slide_no;					// address slide number (ASCII)
	ld a, '1';							// inccrement first ASCII digit
	ld (hl), a;							// to '00'
	inc hl;								// address second ASCII digit
	ld a, '0' - 1;						// will loop to '0'
	ld (hl), a;							// set it

	call show_slide;					// display slide 10
	call show_slide;					// display slide 11
	call show_slide;					// display slide 12

space:
	ld a, $7f;							// high byte of I/O address
	in a, ($fe);						// read byte
	rra;								// set carry if space pressed
	jp c, space;						// loop until space pressed
	jp startshow;						// back to the start

show_slide:
	ld hl, slide_no + 1;				// address second ASCII digit
	ld a, (hl);							// get it
	inc a;								// increment it
	ld (hl), a;							// write it back
	ld ix, slide;						// ASCIIZ filename
	call open;							// open file

	ld ix, $c000;						// offset 0 in frame buffer
	ld bc, 6144;						// byte count
	call load;							// load the 1st half of file

	ld ix, $e000;						// offset 1 in frame buffer
	ld bc, 6208;						// byte count
	call load;							// load the 2nd half of the file + palette
	call close;							// close file

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

	call pause;							// wait for key press

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

	ret;								// done

;	// subroutines

; FIXME - make the call to set the palette an API call
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

pause:
	ld b, 180;							// frames/2 to wait

pause2:
	call wait;							// wait 2 frames
	djnz pause2;
	ret;								// done

load:
	ld a, (handle);						// file handle
	jp SEFileRead;						// exit via read file vector

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

roll_text:
	ld hl, back_buffer;					// source
	ld (hl), 0;							// clar it
    ld de, back_buffer + 1;		       	// destination
    ld bc, 6143;				        // byte count
    ldir;               				// clear it

	ld bc, $bf3b;						// palette port
	xor a;								// register 0 (first foreground value)
	out (c), a;							// select register
	ld a, $ff;							// bright white
	ld b, a;							// data port
	out (c), a;							// write palette entry

	call clear_screen;					// clear it

	ld a, %00011101;					// ROM 1, video 1, RAM 5
	ld bc, $7ffd;						// 128 paging
	out (c), a;							// set it

	call clear_screen;					// clear it

	ld ix, filename;					// point to data
	call open;							// open file for reading

skip_header:
	ld ix, $a7c2;						// 62 bytes before back buffer
	ld bc, 62;							// BMP header
	call load;							// read file	

main_loop:
	call scroll;						// scroll the back buffer up one pixel

	ld ix, $bfe0;						// last line of back buffer
	ld bc, 32;							// byte count
	call load;							// read file	

;	//  if end of file reached, BC will be 2
	dec bc;								// reduce BC
	dec bc;
	ld a, c;							// test for zero
	or b;
	jr z, close;						// exit if done

	ld a, (reg);						// get video / RAM page
	xor %00000010;						// change RAM page
	ld bc, $7ffd;						// 128 paging
	out (c), a;							// set it

    ld hl, $a800;       				// back buffer
    ld de, $c000;     					// currently paged out frame buffer
    ld bc, 6144;      					// byte count
    ldir;               				// copy it

	xor %00001000;						// chage video page
	ld (reg), a;						// store it
	ld bc, $7ffd;						// 128 paging

	halt;								// this should wait for a vblank

	out (c), a;							// set it

	halt;								// wait for a second vblank

	jp main_loop;						// do next line

;	// subroutines

close:
	ld a, (handle);						// get folder handle
	jp SEFileClose;						// exit via close file vector

scroll:
    ld ix, row_table;   				// table of addresses
    ld a, 191;          				// number of rows to copy

do_rows:
    ld e, (ix);         				// destination
    ld d, (ix + 1);
    ld l, (ix + 2);     				// source
    ld h, (ix + 3);
    ld bc, 32;          				// byte count
    ldir;               				// copy it
    inc ix;             				// advance 
    inc ix;             				// one row
    dec a;              				// reduce count
    and a;              				// test for zero
    jr nz, do_rows;     				// loop until done
	ret;

clear_screen:
	ld hl, $c000;						// source
	ld (hl), 0;							// clar it
	ld de, $c001;						// destination
	ld bc, 6143;						// byte count
	ldir;								// clear screen
	ld hl, $e000;						// source
	ld (hl), 0;							// clear it
	ld de, $e001;						// destination
	ld bc, 6143;						// byte count
	ldir;								// set attributes
	ret;

;	// file handling
open:
	call SEFileOpenExists;				// open file
	ld (handle), a;						// store file handle
	ret;								// end of subroutine

;	// back buffer lookup table
row_table:
    defw $a800, $a900, $aa00, $ab00, $ac00, $ad00, $ae00, $af00
    defw $a820, $a920, $aa20, $ab20, $ac20, $ad20, $ae20, $af20
    defw $a840, $a940, $aa40, $ab40, $ac40, $ad40, $ae40, $af40
    defw $a860, $a960, $aa60, $ab60, $ac60, $ad60, $ae60, $af60
    defw $a880, $a980, $aa80, $ab80, $ac80, $ad80, $ae80, $af80
    defw $a8a0, $a9a0, $aaa0, $aba0, $aca0, $ada0, $aea0, $afa0
    defw $a8c0, $a9c0, $aac0, $abc0, $acc0, $adc0, $aec0, $afc0
    defw $a8e0, $a9e0, $aae0, $abe0, $ace0, $ade0, $aee0, $afe0

    defw $b000, $b100, $b200, $b300, $b400, $b500, $b600, $b700
    defw $b020, $b120, $b220, $b320, $b420, $b520, $b620, $b720
    defw $b040, $b140, $b240, $b340, $b440, $b540, $b640, $b740
    defw $b060, $b160, $b260, $b360, $b460, $b560, $b660, $b760
    defw $b080, $b180, $b280, $b380, $b480, $b580, $b680, $b780
    defw $b0a0, $b1a0, $b2a0, $b3a0, $b4a0, $b5a0, $b6a0, $b7a0
    defw $b0c0, $b1c0, $b2c0, $b3c0, $b4c0, $b5c0, $b6c0, $b7c0
    defw $b0e0, $b1e0, $b2e0, $b3e0, $b4e0, $b5e0, $b6e0, $b7e0

    defw $b800, $b900, $ba00, $bb00, $bc00, $bd00, $be00, $bf00
    defw $b820, $b920, $ba20, $bb20, $bc20, $bd20, $be20, $bf20
    defw $b840, $b940, $ba40, $bb40, $bc40, $bd40, $be40, $bf40
    defw $b860, $b960, $ba60, $bb60, $bc60, $bd60, $be60, $bf60
    defw $b880, $b980, $ba80, $bb80, $bc80, $bd80, $be80, $bf80
    defw $b8a0, $b9a0, $baa0, $bba0, $bca0, $bda0, $bea0, $bfa0
    defw $b8c0, $b9c0, $bac0, $bbc0, $bcc0, $bdc0, $bec0, $bfc0
    defw $b8e0, $b9e0, $bae0, $bbe0, $bce0, $bde0, $bee0, $bfe0

slide:
	defb "slide_";						// filename for slide

slide_no:
	defb "01";
	defb ".scr", 0;

filename:
	defb "rolltext.bmp", 0;

reg:
	defb 0

handle:
	defb 0

;	// palette entries

fade_0:
	defs 64, 0;							// 0% intensity

fade_1 equ fade_0 + 64
fade_2 equ fade_1 + 64
fade_3 equ fade_2 + 64
fade_4 equ fade_3 + 64
fade_5 equ fade_4 + 64
fade_6 equ fade_5 + 64
fade_7 equ fade_6 + 64

text:
	defb "2019 - Version 1.2", 13;
 	defb "Copyright (C) 2020-2023 Source Solutions, Inc.", 13;
	defb 13;
	defb "In November 2019, Chloe Corporation launched a Patreon to rasie funds for the", 13;
	defb "development of the Chloe 280SE. To accompany the launch event, a short video was", 13;
	defb "produced parodying the open titles of Ridley Scott's ", '"', "Blade Runner", '"', " set in an", 13;
	defb "alternate 2019 (the idea being that the Chloe 280SE is from an alternate 1987).", 13;
	defb 13;
	defb "The video includes a version of the film's opening scroll, replacing Tyrell with", 13;
	defb "Intel, Replicants with Microcomputers, and Retirement with Emulation. The music", 13;
	defb "is ", '"', "If I Didn't Care", '"', " recorded by The Ink Spots in 1939, used in the workprint", 13;
	defb "cut of the film and the theatrical trailer. It is now in the public domain.", 13;
	defb 13;
	defb "Stills from the opening flight over Los Angeles are used as the backdrop to the", 13;
	defb "machine specifications: CPU, RAM, bus speed, palette, VRAM, display modes,", 13;
	defb "character sets, audio, co-processor, ROM, BASIC, file system and I/O devices.", 13;
	defb "Then a still from Scott's 1984 Apple advert, noting open [hard|firm|soft]ware.", 13;
	defb 13;
	defb "The final card also parodies the advert: You'll see why 2019 won't be like 2019.", 13;
	defb "The demo recreates the video, mainly using code from the slideshow app. The", 13;
	defb "scrolling text is done by streaming a BMP file directly to VRAM from disk. The", 13;
	defb "music was added later with the MIDI > Aria Maestosa > Arkos Tracker II workflow.", 13;
	defb 0;

text_lo:
	defb "NOW PRESS SPACE TO START THE DEMO", 0;
